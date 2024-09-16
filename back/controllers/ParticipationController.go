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
	if user.Tokens < int64(activity.Price) {
		if err := database.DB.Save(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la mise à jour des jetons"})
			return
		}

		// Créer une participation sans attribution de points
		participation := models.Participation{
			UserID:     req.UserID,
			ActivityID: req.ActivityID,
		}

		if err := database.DB.Create(&participation).Error; err != nil {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de l'enregistrement de la participation"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":       "Participation enregistrée avec succès",
			"participation": participation,
		})
	}
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
// @Router /participations [put]
func UpdateParticipation(c *gin.Context) {
	var req models.UpdateParticipationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{Error: err.Error()})
		return
	}

	// Vérifier si la participation existe
	var participation models.Participation
	if err := database.DB.First(&participation, req.ParticipationID).Error; err != nil {
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
	var points uint
	if req.IsWinner {
		points = activity.Points * 2 // Le gagnant reçoit le double des points
	} else {
		points = activity.Points // Les participants reçoivent les points de base
	}

	// Mettre à jour la participation avec les points et le statut de gagnant
	participation.Points = points
	participation.IsWinner = req.IsWinner
	if err := database.DB.Save(&participation).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{Error: "Erreur lors de la mise à jour de la participation"})
		return
	}

	c.JSON(http.StatusOK, models.JSONResponse{
		Message: "Participation mise à jour avec succès",
		Data:    participation,
	})
}
