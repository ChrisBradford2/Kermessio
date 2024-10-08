package routes

import (
	"kermessio/controllers"
	middleware "kermessio/middlewares"

	"github.com/gin-gonic/gin"
)

// AuthRoutes defines the authentication-related routes
func AuthRoutes(r *gin.Engine) {
	// Route for user registration
	r.POST("/user/register", controllers.Register)

	// Route for user login
	r.POST("/user/login", controllers.Login)

	protected := r.Group("/user")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.PUT("/user/:id", controllers.UpdateUser)
	}
}
