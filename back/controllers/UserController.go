package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

func GetUserDetails(c *gin.Context) {
	currentUser, exists := c.Get("currentUser")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	user := currentUser.(models.User)

	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"tokens":   user.Tokens,
			"role":     user.Role,
		},
	})
}

// GetStands godoc
// @Summary Get all stands
// @Description Get all stands
// @Tags Stand
// @Accept json
// @Produce json
// @Success 200 {object} gin.H
// @Failure 500 {object} gin.H
// @Router /stands [get]
func GetStands(c *gin.Context) {
	var boothHolders []models.User
	if err := database.DB.Where("role = ?", "booth_holder").
		Preload("Stocks").
		Find(&boothHolders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des stands"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"stands": boothHolders,
	})
}
