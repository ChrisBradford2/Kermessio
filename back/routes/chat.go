package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func WebSocketHandler(c *gin.Context) {
	middleware.HandleWebSocket(c.Writer, c.Request)
}

func ChatMessageRoutes(r *gin.Engine) {
	r.GET("/ws", WebSocketHandler)
	protected := r.Group("/chat")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/conversations", controllers.GetConversations)
		protected.GET("/messages", controllers.GetChatHistory)
		protected.POST("/messages", controllers.SendMessage)
	}
}
