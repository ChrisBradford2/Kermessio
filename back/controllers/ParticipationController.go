package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

// CreateParticipation godoc
// @Summary Create a participation
// @Description Create a participation
// @ID create-participation
// @Accept  json
// @Produce  json
// @Param createParticipationRequest body CreateParticipationRequest true "Create Participation Request"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /participations [post]
func CreateParticipation(c *gin.Context) {
	var req models.CreateParticipationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Vérifier si l'utilisateur existe
	var user models.User
	if err := database.DB.First(&user, req.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Utilisateur non trouvé"})
		return
	}

	// Vérifier si l'activité existe
	var activity models.Activity
	if err := database.DB.First(&activity, req.ActivityID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Activité non trouvée"})
		return
	}

	// Vérifier si l'utilisateur a assez de jetons pour s'inscrire
	if user.Tokens < int64(activity.Price) {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: "Pas assez de jetons pour participer à l'activité"})
		return
	}

	// Déduire les jetons de l'utilisateur
	user.Tokens -= int64(activity.Price)
	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la mise à jour des jetons"})
		return
	}

	// Créer une participation
	participation := models.Participation{
		UserID:     req.UserID,
		ActivityID: req.ActivityID,
		Points:     0, // Initialement, les points peuvent être à 0 jusqu'à ce que le vainqueur soit décidé
		IsWinner:   false,
	}

	if err := database.DB.Create(&participation).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de l'enregistrement de la participation"})
		return
	}

	// Enregistrer l'interaction
	interaction := models.Interaction{
		UserID:     req.UserID,
		ActivityID: &activity.ID,
		StockID:    nil,
		Tokens:     -int(activity.Price),
	}

	if err := database.DB.Create(&interaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de l'enregistrement de l'interaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Participation enregistrée avec succès",
		"participation": participation,
	})
}

// GetParticipationsByActivity godoc
// @Summary Get participations for a specific activity
// @Description Get all participations for a given activity
// @ID get-participations-by-activity
// @Produce  json
// @Param activity_id path int true "Activity ID"
// @Success 200 {object} models.JSONResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /activities/{activity_id}/participations [get]
func GetParticipationsByActivity(c *gin.Context) {
	activityID := c.Param("activity_id")

	var activity models.Activity
	if err := database.DB.First(&activity, activityID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activité non trouvée"})
		return
	}

	var participations []models.Participation
	if err := database.DB.Where("activity_id = ?", activityID).Find(&participations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des participations"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":        "Participations récupérées avec succès",
		"participations": participations,
	})
}

// UpdateParticipation godoc
// @Summary Update a participation with points and winner status
// @Description Update a participation with points and winner status
// @ID update-participation
// @Accept  json
// @Produce  json
// @Param updateParticipationRequest body UpdateParticipationRequest true "Update Participation Request"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /participations/{id} [put]
func UpdateParticipation(c *gin.Context) {
	participationID := c.Param("id")
	var req models.UpdateParticipationRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Vérifier si la participation existe
	var participation models.Participation
	if err := database.DB.First(&participation, participationID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Participation non trouvée"})
		return
	}

	// Vérifier l'activité associée à la participation
	var activity models.Activity
	if err := database.DB.First(&activity, participation.ActivityID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{Error: "Activité non trouvée"})
		return
	}

	// Déterminer les points à attribuer
	points := activity.Points
	if req.IsWinner {
		points *= 2 // Le gagnant reçoit le double des points
	}

	// Mettre à jour la participation avec les points et le statut de gagnant
	participation.Points = points
	participation.IsWinner = req.IsWinner

	// Sauvegarder la mise à jour
	if err := database.DB.Save(&participation).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la mise à jour de la participation"})
		return
	}

	c.JSON(http.StatusOK, models.JSONResponse{
		Message: "Participation mise à jour avec succès",
		Data:    participation,
	})
}
