package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func ActivityRoutes(r *gin.Engine) {
	protected := r.Group("/activities")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("", controllers.CreateActivity)
		protected.GET("", controllers.GetActivities)
		protected.GET("/all", controllers.GetAllActivities)
	}
}
