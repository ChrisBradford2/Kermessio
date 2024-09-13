package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func UserRoutes(r *gin.Engine) {
	protected := r.Group("/")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/user/me", controllers.GetUserDetails)
		protected.POST("/user/child", controllers.CreateChild)
		protected.GET("/user/child", controllers.GetChildren)
		protected.POST("/user/child/:childId/tokens", controllers.AssignTokensToChild)
	}
}
