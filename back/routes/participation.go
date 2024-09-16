package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func ParticipationRoutes(r *gin.Engine) {
	protected := r.Group("/participations")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("", controllers.CreateParticipation)
	}
}
