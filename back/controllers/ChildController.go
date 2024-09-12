package controllers

import (
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

// CreateChild godoc
// @Summary Create a child account
// @Description Create a child account linked to the current authenticated parent
// @Tags children
// @Accept json
// @Produce json
// @Param input body struct{username string, password string} true "Child account details"
// @Security ApiKeyAuth
// @Success 200 {object} gin.H{"message": "Child account created successfully", "child": "child_username"}
// @Failure 400 {object} gin.H{"error": "Bad Request"}
// @Failure 401 {object} gin.H{"error": "Unauthorized"}
// @Failure 500 {object} gin.H{"error": "Failed to create child account"}
// @Router /user/child [post]
func CreateChild(c *gin.Context) {
	var input struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required,min=6"`
	}

	// Bind input from the request
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get the parent from the current authenticated user (assumes middleware sets this)
	parent, exists := c.Get("currentUser")
	if !exists || parent == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Convert the parent to the User model
	parentUser, ok := parent.(models.User)
	if !ok || parentUser.Role != "parent" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Only parents can create child accounts"})
		return
	}

	// Hash the child's password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Create the child account linked to the parent
	child := models.User{
		Username: input.Username,
		Password: string(hashedPassword),
		Role:     "enfant",       // Role is set as "enfant"
		ParentID: &parentUser.ID, // Link to the parent
	}

	// Save the child account in the database
	if err := database.DB.Create(&child).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create child account"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Child account created successfully", "child": child.Username})
}
