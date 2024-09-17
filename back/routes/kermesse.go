package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func KermesseRoutes(r *gin.Engine) {
	protected := r.Group("/kermesses")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("", controllers.CreateKermesse)
		protected.GET("", controllers.GetOrganizersKermesses)
	}
}
