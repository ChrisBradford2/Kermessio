package controllers

import (
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"kermessio/config"
	"kermessio/database"
	"kermessio/models"
	"math/rand"
	"net/http"
	"time"
)

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

// Login godoc
// @Summary Login
// @Description Logs in a user
// @Tags auth
// @Accept json
// @Produce json
// @Param credentials body models.UserLogin true "User credentials"
// @Success 200 {string} string "Token"
// @Failure 400 {object} models.ErrorResponse "Invalid request"
// @Failure 401 {object} models.ErrorResponse "Invalid request"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /user/login [post]
func Login(c *gin.Context) {
	var input struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	// Bind JSON request body to the input struct
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find the user in the database
	var user models.User
	if err := database.DB.Where("username = ?", input.Username).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Check if the password is correct
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Generate JWT token
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		Username: input.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(config.JWTSecret)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	// Return both token and user info in the response
	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"role":     user.Role,
			"tokens":   user.Tokens,
		},
	})
}

// Register godoc
// @Summary Register
// @Description Registers a new user
// @Tags auth
// @Accept json
// @Produce json
// @Param user body models.UserRegister true "User details"
// @Success 200 {string} string "Registration successful"
// @Failure 400 {object} models.ErrorResponse "Invalid request"
// @Failure 500 {object} models.ErrorResponse "Internal server error"
// @Router /user/register [post]
func Register(c *gin.Context) {
	input := models.UserRegister{}

	// Bind JSON request body to the input struct
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	fmt.Println("Rôle reçu :", input.Role)

	var existingUser models.User

	// Vérifier si le nom d'utilisateur existe déjà
	if err := database.DB.Where("username = ?", input.Username).First(&existingUser).Error; err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		// Si une erreur autre que "record not found" est rencontrée, la retourner
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la vérification du nom d'utilisateur"})
		return
	} else if err == nil {
		// Si on trouve un utilisateur avec le même nom d'utilisateur, renvoyer une erreur
		c.JSON(http.StatusConflict, gin.H{"error": "Le nom d'utilisateur est déjà utilisé"})
		return
	}

	// Vérifier si l'email existe déjà
	if err := database.DB.Where("email = ?", input.Email).First(&existingUser).Error; err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		// Si une erreur autre que "record not found" est rencontrée, la retourner
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la vérification de l'email"})
		return
	} else if err == nil {
		// Si on trouve un utilisateur avec le même email, renvoyer une erreur
		c.JSON(http.StatusConflict, gin.H{"error": "L'email est déjà utilisé"})
		return
	}

	// Validate role
	validRoles := []string{config.RoleParent, config.RoleChild, config.RoleBoothHolder, config.RoleOrganizer}
	isValidRole := false
	for _, role := range validRoles {
		if input.Role == role {
			isValidRole = true
			break
		}
	}

	if !isValidRole {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid role provided"})
		return
	}

	// For roles other than "child", ensure that an email is provided and valid
	if input.Role != config.RoleChild && input.Email == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email is required for non-child roles"})
		return
	}

	// Vérifier si l'école existe
	var school models.School
	if err := database.DB.First(&school, input.SchoolID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "École non trouvée"})
		return
	}

	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	x, y := 0, 0
	if input.Role == config.RoleBoothHolder {
		source := rand.NewSource(time.Now().UnixNano())
		r := rand.New(source)
		x = r.Intn(10)
		y = r.Intn(10)
	}
	// Create a new user in the database
	user := models.User{
		Username:  input.Username,
		LastName:  input.LastName,
		FirstName: input.FirstName,
		Email:     input.Email,
		Password:  string(hashedPassword),
		Role:      input.Role,
		PositionX: x,
		PositionY: y,
		SchoolID:  input.SchoolID,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registration successful"})
}
