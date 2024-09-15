package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

// CreateActivity godoc
// @Summary Create an activity
// @Description Create an activity
// @ID create-activity
// @Accept  json
// @Produce  json
// @Param createActivityRequest body models.CreateActivityRequest true "Create Activity Request"
// @Success 200 {object} JSONResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Security ApiKeyAuth
// @Router /activities [post]
func CreateActivity(c *gin.Context) {
	boothHolder, exists := c.Get("currentUser")
	if !exists || boothHolder == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non autorisé"})
		return
	}

	user, ok := boothHolder.(models.User)
	if !ok || user.Role != "booth_holder" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Seuls les teneurs de stand peuvent créer des activités"})
		return
	}

	// Link the booth holder to the activity
	var req models.CreateActivityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create a new activity
	newActivity := models.Activity{
		Name:          req.Name,
		Type:          req.Type,
		Emoji:         req.Emoji,
		Price:         req.Price,
		Points:        req.Points,
		BoothHolderID: user.ID,
	}

	// Save the new activity to the database
	if err := database.DB.Create(&newActivity).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création de l'activité"})
		return
	}

	// Return the new activity
	c.JSON(http.StatusOK, gin.H{
		"message":  "Activité créée avec succès",
		"activity": newActivity,
	})
}
