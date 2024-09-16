package controllers

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"kermessio/database"
	"kermessio/models"
	"net/http"
	"strconv"
)

// CreateStock godoc
// @Summary Create a stock
// @Description Create a stock
// @ID create-stock
// @Accept  json
// @Produce  json
// @Param createStockRequest body CreateStockRequest true "Create Stock Request"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks [post]
func CreateStock(c *gin.Context) {
	boothHolder, exists := c.Get("currentUser")
	if !exists || boothHolder == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non autorisé"})
		return
	}

	user, ok := boothHolder.(models.User)
	if !ok || user.Role != "booth_holder" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Seuls les teneurs de stand peuvent ajouter des stocks"})
		return
	}

	var req models.Stock
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Type != models.Beverage && req.Type != models.Food {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Type invalide. Choisissez 'Boisson' ou 'Nourriture'"})
		return
	}

	newStock := models.Stock{
		ItemName: req.ItemName,
		Type:     req.Type,
		Quantity: req.Quantity,
		Price:    req.Price,
		UserID:   user.ID,
	}

	if err := database.DB.Create(&newStock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création du stock"})
		return
	}

	c.JSON(http.StatusOK, newStock)
}

// GetStocks godoc
// @Summary Get all stocks
// @Description Get all stocks
// @ID get-stocks
// @Accept  json
// @Produce  json
// @Success 200 {object} models.JSONResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks [get]
func GetStocks(c *gin.Context) {
	var stocks []models.Stock

	user, exists := c.Get("currentUser")
	if !exists || user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non autorisé"})
		return
	}

	currentUser, ok := user.(models.User)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Impossible de récupérer les informations de l'utilisateur"})
		return
	}

	if err := database.DB.Where("user_id = ?", currentUser.ID).Find(&stocks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des stocks"})
		return
	}

	if len(stocks) == 0 {
		c.JSON(http.StatusOK, gin.H{"message": "Aucun stock trouvé", "data": []models.Stock{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Stocks récupérés avec succès",
		"data":    stocks,
	})
}

// GetAllStocks godoc
// @Summary Get all stocks
// @Description Get all stocks
// @ID get-all-stocks
// @Accept  json
// @Produce  json
// @Param limit query int false "Limit"
// @Param page query int false "Page"
// @Success 200 {object} models.JSONResponse
// @Failure 500 {object} models.ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks/all [get]
func GetAllStocks(c *gin.Context) {
	var stocksWithUsers []struct {
		models.Stock
		BoothHolderUsername string `json:"booth_holder_username"`
	}

	limit := 10
	page := 1

	if c.Query("limit") != "" {
		parsedLimit, err := strconv.Atoi(c.Query("limit"))
		if err == nil && parsedLimit > 0 {
			limit = parsedLimit
		}
	}

	if c.Query("page") != "" {
		parsedPage, err := strconv.Atoi(c.Query("page"))
		if err == nil && parsedPage > 0 {
			page = parsedPage
		}
	}

	offset := (page - 1) * limit

	if err := database.DB.Table("stocks").
		Select("stocks.*, users.username as booth_holder_username").
		Joins("left join users on users.id = stocks.user_id").
		Where("users.role = ?", "booth_holder").
		Limit(limit).Offset(offset).
		Find(&stocksWithUsers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des stocks"})
		return
	}

	if len(stocksWithUsers) == 0 {
		c.JSON(http.StatusOK, gin.H{"message": "Aucun stock trouvé", "data": []models.Stock{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Stocks récupérés avec succès",
		"data":    stocksWithUsers,
		"page":    page,
		"limit":   limit,
	})
}

// BuyStock godoc
// @Summary Buy a stock
// @Description Allow a child to buy a stock from a booth holder
// @ID buy-stock
// @Accept  json
// @Produce  json
// @Param buyStockRequest body models.BuyStockRequest true "Buy Stock Request"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks/buy [post]
func BuyStock(c *gin.Context) {
	var req models.BuyStockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get the booth holder
	var boothHolder models.User
	if err := database.DB.First(&boothHolder, req.BoothHolderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Teneur de stand non trouvé"})
		return
	}

	// Get the stock
	var stock models.Stock
	if err := database.DB.First(&stock, req.StockID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stock non trouvé"})
		return
	}

	// Check if there is enough stock quantity
	if stock.Quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Stock épuisé"})
		return
	}

	// Get the child
	child, exists := c.Get("currentUser")
	if !exists || child == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non autorisé"})
		return
	}

	currentUser, ok := child.(models.User)
	if !ok || currentUser.Role != "child" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Seuls les enfants peuvent acheter des stocks"})
		return
	}

	// Check if the child has enough tokens
	if currentUser.Tokens < int64(stock.Price) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pas assez de jetons pour acheter ce stock"})
		return
	}

	// Deduct the tokens from the child
	if err := database.DB.Model(&currentUser).Update("tokens", gorm.Expr("tokens - ?", stock.Price)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour des jetons de l'enfant"})
		return
	}

	// Add the tokens to the booth holder
	if err := database.DB.Model(&boothHolder).Update("tokens", gorm.Expr("tokens + ?", stock.Price)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour des jetons du teneur de stand"})
		return
	}

	// Decrease the stock quantity
	if err := database.DB.Model(&stock).Update("quantity", gorm.Expr("quantity - 1")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour de la quantité du stock"})
		return
	}

	// Create a new stock for the child
	newStock := models.Stock{
		ItemName: stock.ItemName,
		Type:     stock.Type,
		Quantity: 1,
		Price:    stock.Price,
		UserID:   currentUser.ID,
	}

	if err := database.DB.Create(&newStock).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création du stock pour l'enfant"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achat effectué avec succès", "stock": newStock})
}
