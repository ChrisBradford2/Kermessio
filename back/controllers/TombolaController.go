package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
	"strconv"
)

func GetTombolaByKermesse(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de kermesse invalide"})
		return
	}

	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	c.JSON(http.StatusOK, tombola)
}

func BuyTombolaTicket(c *gin.Context) {
	var req struct {
		UserID     uint `json:"user_id" binding:"required"`
		KermesseID uint `json:"kermesse_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Vérifier si la tombola existe pour cette kermesse
	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", req.KermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	// Vérifier si l'utilisateur existe
	var user models.User
	if err := database.DB.First(&user, req.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur non trouvé"})
		return
	}

	if user.Role != "child" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Seuls les enfants peuvent acheter des tickets de tombola"})
		return
	}

	// Vérifier si l'utilisateur est déjà participant à la tombola
	participants := database.DB.Model(&tombola).Association("Participants")
	if participants.Find(&user) != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "L'utilisateur a déjà acheté un ticket de tombola"})
		return
	}

	// Ajouter l'utilisateur à la liste des participants
	if err := participants.Append(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'ajout du participant"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Ticket de tombola acheté avec succès",
		"success": true,
		"user":    user,
	})
}

func CheckIfUserHasTicket(c *gin.Context) {
	userID := c.Param("userId")
	kermesseID := c.Param("kermesseId")

	// Vérifier si l'utilisateur a un ticket pour la tombola
	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur non trouvé"})
		return
	}

	// Vérifier si l'utilisateur est déjà participant
	isParticipant := database.DB.Model(&tombola).Where("user_id = ?", userID).Association("Participants").Count() > 0

	c.JSON(http.StatusOK, gin.H{"has_ticket": isParticipant})
}
