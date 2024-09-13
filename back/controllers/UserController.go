package controllers

import (
	"github.com/gin-gonic/gin"
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
