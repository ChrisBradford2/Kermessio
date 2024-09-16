package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
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
