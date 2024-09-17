package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func StockRoutes(r *gin.Engine) {
	protected := r.Group("/stocks")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("", controllers.CreateStock)
		protected.GET("", controllers.GetStocks)
		protected.GET("/all", controllers.GetAllStocks)
	}
}
