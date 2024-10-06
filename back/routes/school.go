package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
)

func SchoolRoutes(r *gin.Engine) {
	r.GET("/schools", controllers.GetSchools)
	r.POST("/schools", controllers.CreateSchool)
}
