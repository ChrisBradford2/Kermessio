package main

import (
	"kermessio/config"
	"kermessio/database"
	"kermessio/docs"
	middleware "kermessio/middlewares"
	"kermessio/models"
	"kermessio/routes"
	"log"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/madkins23/gin-utils/pkg/ginzero"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @termsOfService  http://swagger.io/terms/
// @contact.name   API Support
// @contact.url    http://www.swagger.io/support
// @contact.email  support@swagger.io
//
// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html
//
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
// @description Bearer token
//
// @externalDocs.description  OpenAPI
// @externalDocs.url          https://swagger.io/resources/open-api/
func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Initialize Stripe with the API key
	config.InitStripe()

	// Database connection
	if err := database.ConnectDatabase(); err != nil {
		log.Fatalf("Could not connect to the database: %v", err)
	}

	// Migrate the schema in a controlled order
	if err := database.DB.AutoMigrate(&models.User{}); err != nil {
		log.Fatal("Failed to migrate users: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Activity{}); err != nil {
		log.Fatal("Failed to migrate activities: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Participation{}); err != nil {
		log.Fatal("Failed to migrate participations: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Stock{}); err != nil {
		log.Fatal("Failed to migrate stocks: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Purchase{}); err != nil {
		log.Fatal("Failed to migrate purchases: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Kermesse{}); err != nil {
		log.Fatal("Failed to migrate kermesses: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Tombola{}); err != nil {
		log.Fatal("Failed to migrate tombolas: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Interaction{}); err != nil {
		log.Fatal("Failed to migrate interactions: ", err)
	}
	if err := database.DB.AutoMigrate(&models.Transaction{}); err != nil {
		log.Fatal("Failed to migrate transactions: ", err)
	}
	if err := database.DB.AutoMigrate(&models.ChatMessage{}); err != nil {
		log.Fatal("Failed to migrate chats: ", err)
	}
	if err := database.DB.AutoMigrate(&models.School{}); err != nil {
		log.Fatal("Failed to migrate schools: ", err)
	}
	log.Println("Database migrated!")

	if os.Getenv("GO_ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Set up Gin router
	r := gin.New()
	r.Use(ginzero.Logger())

	// Configure Gin to recover from panics
	r.Use(gin.Recovery())

	// Configure CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:  []string{"*"},
		AllowMethods:  []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:  []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders: []string{"Content-Length"},
		//AllowCredentials: true,
		MaxAge: 12 * time.Hour,
	}))

	// Default route
	r.GET("/", func(c *gin.Context) {
		c.String(200, "hello, gin-zerolog example")
		log.Println("Hello, gin-zerolog example")
	})

	routes.AuthRoutes(r)
	routes.UserRoutes(r)
	routes.PaymentIntentRoutes(r)
	routes.ActivityRoutes(r)
	routes.StockRoutes(r)
	routes.ParticipationRoutes(r)
	routes.PurchaseRoutes(r)
	routes.KermesseRoutes(r)
	routes.TombolaRoutes(r)
	routes.ChatMessageRoutes(r)
	routes.SchoolRoutes(r)

	go middleware.HandleMessages()

	// Swagger documentation
	docs.SwaggerInfo.Title = "Kermessio API"
	docs.SwaggerInfo.Description = "API for Kermessio"
	docs.SwaggerInfo.Version = "1.0"
	docs.SwaggerInfo.BasePath = "/"
	docs.SwaggerInfo.Host = "localhost:8080"
	docs.SwaggerInfo.Schemes = []string{"http"}
	r.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server: ", err)
	}
}
