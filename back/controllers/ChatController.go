package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
	"strconv"
)

func GetConversations(c *gin.Context) {
	currentUser, exists := c.Get("currentUser")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	user := currentUser.(models.User)

	// Vérifier le rôle de l'utilisateur
	var query string
	var conversations []struct {
		UserID      uint   `json:"user_id"`
		Username    string `json:"username"`
		LastMessage string `json:"last_message"`
	}

	// Si l'utilisateur est un organisateur
	if user.Role == "organizer" {
		query = `
			SELECT DISTINCT ON (receiver_id)
				receiver_id AS user_id,
				users.username AS username,
				chat_messages.message AS last_message
			FROM chat_messages
			JOIN users ON chat_messages.receiver_id = users.id
			WHERE chat_messages.sender_id = ?
			ORDER BY receiver_id, chat_messages.created_at DESC
		`
	} else if user.Role == "booth_holder" { // Si l'utilisateur est un teneur de stand
		query = `
			SELECT DISTINCT ON (sender_id)
				sender_id AS user_id,
				users.username AS username,
				chat_messages.message AS last_message
			FROM chat_messages
			JOIN users ON chat_messages.sender_id = users.id
			WHERE chat_messages.receiver_id = ?
			ORDER BY sender_id, chat_messages.created_at DESC
		`
	} else {
		c.JSON(http.StatusForbidden, gin.H{"error": "Rôle utilisateur non pris en charge"})
		return
	}

	err := database.DB.Raw(query, user.ID).Scan(&conversations).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des conversations"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"conversations": conversations})
}

func GetChatHistory(c *gin.Context) {
	// Vérifier que l'utilisateur est authentifié
	currentUser, exists := c.Get("currentUser")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	// Récupérer les paramètres
	senderIDParam := c.Query("sender_id")
	receiverIDParam := c.Query("receiver_id")

	if senderIDParam == "" || receiverIDParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Les paramètres sender_id et receiver_id sont requis"})
		return
	}

	// Convertir les paramètres en int
	senderID, err := strconv.Atoi(senderIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "sender_id doit être un entier valide"})
		return
	}

	receiverID, err := strconv.Atoi(receiverIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "receiver_id doit être un entier valide"})
		return
	}

	user := currentUser.(models.User)
	if user.ID != uint(senderID) && user.ID != uint(receiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Accès non autorisé à cette conversation"})
		return
	}

	var messages []models.ChatMessage
	if err := database.DB.
		Preload("Sender").
		Preload("Receiver").
		Where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
			senderID, receiverID, receiverID, senderID).
		Order("created_at asc").
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des messages"})
		return
	}

	// Retourner les messages
	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

func SendMessage(c *gin.Context) {
	var input struct {
		SenderID   uint   `json:"sender_id" binding:"required"`
		ReceiverID uint   `json:"receiver_id" binding:"required"`
		Message    string `json:"message" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	message := models.ChatMessage{
		SenderID:   input.SenderID,
		ReceiverID: input.ReceiverID,
		Message:    input.Message,
	}

	if err := database.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'envoi du message"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Message envoyé avec succès"})
}
