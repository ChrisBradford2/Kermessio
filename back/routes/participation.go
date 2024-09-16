package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func ParticipationRoutes(r *gin.Engine) {
	protected := r.Group("")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("/participations", controllers.CreateParticipation)
		protected.GET("/activities/:activity_id/participations", controllers.GetParticipationsByActivity)
		protected.PUT("/participations/:id", controllers.UpdateParticipation)
	}
}
