package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"log"
	"net/http"
	"strconv"
)

func generateInvitationCode(kermesseID uint) string {
	return "INVITATION_CODE_" + strconv.Itoa(int(kermesseID))
}

func CreateKermesse(c *gin.Context) {
	var req struct {
		Name string `json:"name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	organizer, exists := c.Get("currentUser")
	if !exists || organizer == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	currentUser, ok := organizer.(models.User)
	if !ok || currentUser.Role != "organizer" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Seuls les organisateurs peuvent créer des kermesses"})
		return
	}

	var school models.School
	if err := database.DB.Where("id = ?", currentUser.SchoolID).First(&school).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération de l'école de l'organisateur"})
		return
	}

	kermesse := models.Kermesse{
		Name: req.Name,
		Organizers: []models.User{
			currentUser,
		},
		SchoolID: school.ID,
	}

	if err := database.DB.Create(&kermesse).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création de la kermesse"})
		return
	}

	tombola := models.Tombola{
		KermesseID: kermesse.ID,
	}

	if err := database.DB.Create(&tombola).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création de la tombola"})
		return
	}


	invitationCode := generateInvitationCode(kermesse.ID)
	if err := database.DB.Model(&kermesse).Update("invitation_code", invitationCode).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour du code d'invitation"})
		return
	}

	kermesse.InvitationCode = invitationCode

	c.JSON(http.StatusOK, gin.H{
		"message":         "Kermesse créée avec succès",
		"invitation_code": invitationCode,
		"kermesse":        kermesse,
		"tombola":         tombola,
	})
}

// JoinKermesse godoc
// @Summary Join a kermesse
// @Description Join a kermesse
// @Tags kermesses
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param invitation_code body string true "Invitation code"
// @Success 200 {object} models.Kermesse
// @Router /kermesses/join [post]
func JoinKermesse(c *gin.Context) {
	var req struct {
		InvitationCode string `json:"invitation_code" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	organizer, exists := c.Get("currentUser")
	if !exists || organizer == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	currentUser, ok := organizer.(models.User)
	if !ok || currentUser.Role != "organizer" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Seuls les organisateurs peuvent rejoindre des kermesses"})
		return
	}

	var kermesse models.Kermesse
	if err := database.DB.Where("invitation_code = ?", req.InvitationCode).First(&kermesse).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Kermesse non trouvée"})
		return
	}

	if err := database.DB.Model(&kermesse).Association("Organizers").Append(&currentUser); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la jointure de la kermesse"})
	}

	c.JSON(http.StatusOK, gin.H{"message": "Vous avez rejoint la kermesse avec succès", "kermesse": kermesse})
}

// GetUserKermesses godoc
// @Summary Get the kermesses of the current user
// @Description Get the kermesses of the current user
// @Tags kermesses
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} models.Kermesse
// @Router /kermesses [get]
func GetUserKermesses(c *gin.Context) {
	currentUser, exists := c.Get("currentUser")
	if !exists || currentUser == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	user, ok := currentUser.(models.User)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non trouvé"})
		return
	}

	var kermesses []models.Kermesse

	// Organisateur : récupère les kermesses organisées par l'utilisateur
	if user.Role == "organizer" {
		if err := database.DB.Preload("KermessesAsOrganizer").Where("id = ?", user.ID).Find(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des kermesses pour l'organisateur"})
			return
		}
		kermesses = user.KermessesAsOrganizer
	} else {
		// Participant : cherche les kermesses de l'école
		if err := database.DB.Preload("KermessesAsParticipant").Where("id = ?", user.ID).Find(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des kermesses pour le participant"})
			return
		}

		var schoolKermesses []models.Kermesse
		if err := database.DB.Where("school_id = ?", user.SchoolID).Find(&schoolKermesses).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des kermesses de l'école"})
			return
		}

		for _, kermesse := range schoolKermesses {
			// Si l'utilisateur n'est pas déjà un participant de cette kermesse
			if !containsKermesse(user.KermessesAsParticipant, kermesse) {
				if err := database.DB.Model(&kermesse).Association("Participants").Append(&user); err != nil {
					log.Printf("Erreur lors de l'ajout de l'utilisateur à la kermesse: %v", err)
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'ajout de l'utilisateur à la kermesse"})
					return
				}
			}
		}

		// Recharger les kermesses de l'utilisateur
		if err := database.DB.Preload("KermessesAsParticipant").Where("id = ?", user.ID).Find(&user).Error; err != nil {
			log.Printf("Erreur lors de la récupération des kermesses: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des kermesses pour le participant"})
			return
		}

		kermesses = user.KermessesAsParticipant
	}

	// Retourner les kermesses
	c.JSON(http.StatusOK, gin.H{"kermesses": kermesses})
}

// Fonction utilitaire pour vérifier si un utilisateur est déjà inscrit à une kermesse
func containsKermesse(kermesses []models.Kermesse, kermesse models.Kermesse) bool {
	for _, k := range kermesses {
		if k.ID == kermesse.ID {
			return true
		}
	}
	return false
}
