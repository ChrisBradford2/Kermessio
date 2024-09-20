package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func UserRoutes(r *gin.Engine) {
	protected := r.Group("/user")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/me", controllers.GetUserDetails)
		protected.POST("/child", controllers.CreateChild)
		protected.GET("/child", controllers.GetChildren)
		protected.POST("/child/:childId/tokens", controllers.AssignTokensToChild)
		protected.GET("/child/:childId/interactions", controllers.GetChildInteractions)

		// Route for organizer role
		protected.GET("/organizer/:kermesseId/revenue", controllers.GetKermesseRevenue)
		protected.GET("/organizer/stands", controllers.GetStands)
	}
}
