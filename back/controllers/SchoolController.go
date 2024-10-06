package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

func GetSchools(c *gin.Context) {
	var schools []models.School
	if err := database.DB.Find(&schools).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Unable to fetch schools"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"schools": schools})
}

func CreateSchool(c *gin.Context) {
	var input models.School
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := database.DB.Create(&input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Unable to create school"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "School created successfully"})
}
