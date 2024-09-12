package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
)

// AuthRoutes defines the authentication-related routes
func AuthRoutes(r *gin.Engine) {
	// Route for user registration
	r.POST("/user/register", controllers.Register)

	// Route for user login
	r.POST("/user/login", controllers.Login)
}
