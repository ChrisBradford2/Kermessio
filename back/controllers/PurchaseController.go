package controllers

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"kermessio/database"
	"kermessio/models"
	"math/rand"
	"net/http"
	"time"
)

func generateValidationCode() string {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	letters := []rune("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
	code := make([]rune, 6)
	for i := range code {
		code[i] = letters[r.Intn(len(letters))]
	}
	return string(code)
}

// CreatePurchase godoc
// @Summary Create a purchase
// @Description Create a purchase
// @ID create-purchase
// @Accept  json
// @Produce  json
// @Param buyStockRequest body models.BuyStockRequest true "Buy Stock Request"
// @Success 200 {object} models.Purchase
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks/buy [post]
func CreatePurchase(c *gin.Context) {
	var req models.BuyStockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Vérifier l'existence du stock et du teneur de stand
	var boothHolder models.User
	if err := database.DB.First(&boothHolder, req.BoothHolderID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Teneur de stand non trouvé"})
		return
	}

	var stock models.Stock
	if err := database.DB.First(&stock, req.StockID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stock non trouvé"})
		return
	}

	// Vérifier la quantité disponible
	if stock.Quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Stock épuisé"})
		return
	}

	// Récupérer l'utilisateur enfant
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

	// Vérifier que l'enfant a assez de jetons
	if currentUser.Tokens < int64(stock.Price) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pas assez de jetons pour acheter ce stock"})
		return
	}

	// Déduire les jetons de l'enfant et les ajouter au teneur de stand
	if err := database.DB.Model(&currentUser).Update("tokens", gorm.Expr("tokens - ?", stock.Price)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour des jetons de l'enfant"})
		return
	}

	if err := database.DB.Model(&boothHolder).Update("tokens", gorm.Expr("tokens + ?", stock.Price)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour des jetons du teneur de stand"})
		return
	}

	// Diminuer la quantité du stock
	if err := database.DB.Model(&stock).Update("quantity", gorm.Expr("quantity - 1")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour de la quantité du stock"})
		return
	}

	validationCode := generateValidationCode()

	// Créer un enregistrement d'achat
	purchase := models.Purchase{
		UserID:         currentUser.ID,
		StockID:        stock.ID,
		Quantity:       1,
		Price:          stock.Price,
		ValidationCode: validationCode,
		Status:         models.Pending,
	}

	if err := database.DB.Create(&purchase).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'enregistrement de l'achat"})
		return
	}

	// Enregistrer l'interaction
	interaction := models.Interaction{
		UserID:     currentUser.ID,
		StockID:    &stock.ID,
		ActivityID: nil,
		Tokens:     stock.Price * -1,
	}

	if err := database.DB.Create(&interaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'enregistrement de l'interaction"})
		return
	}

	if err := database.DB.Preload("Stock").First(&purchase).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors du chargement des détails de l'achat"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achat effectué avec succès", "purchase": purchase})
}

// GetPurchasesByUser godoc
// @Summary Get purchases by user ID
// @Description Retrieve all purchases made by a specific user
// @ID get-purchases-by-user
// @Produce  json
// @Param id path int true "User ID"
// @Success 200 {object} []models.Purchase
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /users/{id}/purchases [get]
func GetPurchasesByUser(c *gin.Context) {
	userID := c.Param("id")

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Utilisateur non trouvé"})
		return
	}

	var purchases []models.Purchase
	if err := database.DB.Where("user_id = ?", userID).Preload("Stock").Find(&purchases).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la récupération des achats"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"purchases": purchases,
	})
}

// ValidatePurchaseById godoc
// @Summary Validate a purchase by ID
// @Description Validate a purchase by ID
// @ID validate-purchase-code
// @Accept  json
// @Produce  json
// @Param code body string true "Validation Code"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /purchases/validate [post]
func ValidatePurchaseById(c *gin.Context) {
	var req struct {
		PurchaseID uint `json:"purchaseId"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Rechercher l'achat correspondant à l'ID
	var purchase models.Purchase
	if err := database.DB.Preload("Stock").Where("id = ?", req.PurchaseID).First(&purchase).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Achat non trouvé"})
		return
	}

	// Vérifier si le statut de l'achat est encore "pending"
	if purchase.Status != models.Pending {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Cet achat a déjà été validé ou rejeté"})
		return
	}

	// Valider l'achat (changer le statut à "approved")
	purchase.Status = models.Approved
	if err := database.DB.Save(&purchase).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la validation de l'achat"})
		return
	}

	// Retourner les détails de l'achat validé
	c.JSON(http.StatusOK, models.JSONResponse{
		Message: "Achat validé avec succès",
		Data:    purchase,
	})
}

// VerifyPurchaseCode godoc
// @Summary Verify a purchase code
// @Description Verify if the purchase code is valid and return the purchase details
// @ID verify-purchase-code
// @Accept  json
// @Produce  json
// @Param code body string true "Validation Code"
// @Success 200 {object} models.Purchase
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Router /purchases/verify [post]
func VerifyPurchaseCode(c *gin.Context) {
	var req struct {
		Code string `json:"code"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	var purchase models.Purchase

	if err := database.DB.Preload("Stock").Where("validation_code = ?", req.Code).First(&purchase).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Code invalide ou commande non trouvée"})
		return
	}

	// Retourner les détails de la commande pour validation
	c.JSON(http.StatusOK, purchase)
}
