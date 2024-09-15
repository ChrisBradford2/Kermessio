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
// @Success 200 {object} JSONResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
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

	// Création du stock dans la base de données
	newStock := models.Stock{
		ItemName: req.ItemName,
		Type:     req.Type,
		Quantity: req.Quantity,
		Price:    req.Price,
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
// @Success 200 {object} JSONResponse
// @Failure 401 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Security ApiKeyAuth
// @Router /stocks [get]
func GetStocks(c *gin.Context) {
	var stocks []models.Stock
	if err := database.DB.Find(&stocks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des stocks"})
		return
	}

	c.JSON(http.StatusOK, stocks)
}
