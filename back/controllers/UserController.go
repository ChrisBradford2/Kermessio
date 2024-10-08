package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
	"strconv"
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
	currentUser, exists := c.Get("currentUser")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	user := currentUser.(models.User)

	if user.Role != "organizer" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Vous n'êtes pas autorisé à accéder à cette ressource"})
		return
	}

	var boothHolders []models.User
	if err := database.DB.Where("role = ? AND school_id = ?", "booth_holder", user.SchoolID).
		Preload("Stocks").
		Find(&boothHolders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des stands"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"stands": boothHolders,
	})
}

func GetOrganizersByKermesseID(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid kermesse ID"})
		return
	}

	var organizers []models.User
	if err := database.DB.
		Table("users").
		Select("users.id, users.username").
		Joins("JOIN kermesse_organizers ON users.id = kermesse_organizers.user_id").
		Where("kermesse_organizers.kermesse_id = ?", kermesseID).
		Find(&organizers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des organisateurs"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"organizers": organizers,
	})
}

func GetPointsRanking(c *gin.Context) {
	currentUser, exists := c.Get("currentUser")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	user := currentUser.(models.User)

	if user.Role != "organizer" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Vous n'êtes pas autorisé à accéder à cette ressource"})
		return
	}

	var users []models.User
	err := database.DB.Where("role = ? AND school_id = ?", "child", user.SchoolID).
		Order("points desc").
		Find(&users).
		Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération du classement"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"ranking": users})
}
