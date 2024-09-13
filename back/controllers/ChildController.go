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
// @Param request body models.ChildRequest true "Child Request"
// @Security ApiKeyAuth
// @Success 200 {object} models.ChildRequestResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /user/child [post]
func CreateChild(c *gin.Context) {
	var input models.ChildRequest

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
		Role:     "child",        // Role is set as "enfant"
		ParentID: &parentUser.ID, // Link to the parent
	}

	// Save the child account in the database
	if err := database.DB.Create(&child).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create child account"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Child account created successfully", "child": child.Username})
}

// GetChildren godoc
// @Summary Get all children linked to the current authenticated parent
// @Description Get all children linked to the current authenticated parent
// @Tags children
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} models.PublicChild
// @Failure 401 {object} models.ErrorResponse
// @Router /user/child [get]
func GetChildren(c *gin.Context) {
	parent, exists := c.Get("currentUser")
	if !exists || parent == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Convert the parent to the User model
	parentUser, ok := parent.(models.User)
	if !ok || parentUser.Role != "parent" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Only parents can view children"})
		return
	}

	// Get all children linked to the parent
	var children []models.User
	if err := database.DB.Where("parent_id = ?", parentUser.ID).Find(&children).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get children"})
		return
	}

	// Convert the children to public users
	var publicChildren []models.PublicChild
	for _, child := range children {
		publicChildren = append(publicChildren, models.PublicChild{
			Base:     child.Base,
			Username: child.Username,
			Tokens:   child.Tokens,
		})
	}

	c.JSON(http.StatusOK, publicChildren)
}
