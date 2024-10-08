package controllers

import (
	"github.com/gin-gonic/gin"
	"kermessio/database"
	"kermessio/models"
	"math/rand"
	"net/http"
	"strconv"
	"time"
)

func GetTombolaByKermesse(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de kermesse invalide"})
		return
	}

	var tombola models.Tombola
	if err := database.DB.Preload("Participants").Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	c.JSON(http.StatusOK, tombola)
}

func BuyTombolaTicket(c *gin.Context) {
	var req struct {
		UserID     uint `json:"user_id" binding:"required"`
		KermesseID uint `json:"kermesse_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Vérifier si la tombola existe pour cette kermesse
	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", req.KermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	// Vérifier si l'utilisateur existe
	var user models.User
	if err := database.DB.First(&user, req.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur non trouvé"})
		return
	}

	if user.Role != "child" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Seuls les enfants peuvent acheter des tickets de tombola"})
		return
	}

	// Vérifier si l'utilisateur est déjà participant à la tombola
	participants := database.DB.Model(&tombola).Association("Participants")
	if participants.Find(&user) != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "L'utilisateur a déjà acheté un ticket de tombola"})
		return
	}

	// Ajouter l'utilisateur à la liste des participants
	if err := participants.Append(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de l'ajout du participant"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Ticket de tombola acheté avec succès",
		"success": true,
		"user":    user,
	})
}

func CheckIfUserHasTicket(c *gin.Context) {
	userID := c.Param("userId")
	kermesseID := c.Param("kermesseId")

	// Vérifier si l'utilisateur a un ticket pour la tombola
	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur non trouvé"})
		return
	}

	// Vérifier si l'utilisateur est déjà participant
	isParticipant := database.DB.Model(&tombola).Where("user_id = ?", userID).Association("Participants").Count() > 0

	c.JSON(http.StatusOK, gin.H{"has_ticket": isParticipant})
}

func DrawTombolaWinner(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de kermesse invalide"})
		return
	}

	// Récupérer la tombola associée à la kermesse
	var tombola models.Tombola
	if err := database.DB.Preload("Participants").Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	// Vérifier si des participants sont inscrits à la tombola
	if len(tombola.Participants) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Aucun participant pour cette tombola"})
		return
	}

	// Vérifier si le tirage a déjà eu lieu
	if tombola.Drawn {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Le tirage a déjà été effectué"})
		return
	}

	source := rand.NewSource(time.Now().UnixNano())
	r := rand.New(source)
	winnerIndex := r.Intn(len(tombola.Participants))
	winner := tombola.Participants[winnerIndex]

	// Marquer la tombola comme tirée
	tombola.Drawn = true
	tombola.WinnerID = &winner.ID 
	if err := database.DB.Save(&tombola).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour de la tombola"})
		return
	}

	// Retourner les informations du gagnant
	c.JSON(http.StatusOK, gin.H{
		"message": "Le tirage a été effectué avec succès",
		"winner": gin.H{
			"id":       winner.ID,
			"username": winner.Username,
			"email":    winner.Email,
		},
	})
}

// GetTombolaStatus godoc
// @Summary Get tombola status
// @Description Get the status of a tombola, including prize and whether the user is a winner
// @ID get-tombola-status
// @Produce json
// @Param kermesseId path int true "Kermesse ID"
// @Param userId path int true "User ID"
// @Success 200 {object} models.JSONResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /tombola/{kermesseId}/status/{userId} [get]
func GetTombolaStatus(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de kermesse invalide"})
		return
	}

	userID, err := strconv.Atoi(c.Param("userId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de l'utilisateur invalide"})
		return
	}

	// Récupérer la tombola associée à la kermesse
	var tombola models.Tombola
	if err := database.DB.Preload("Participants").Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	// Vérifier si l'utilisateur est inscrit à la tombola
	isParticipant := false
	for _, participant := range tombola.Participants {
		if participant.ID == uint(userID) {
			isParticipant = true
			break
		}
	}

	if !isParticipant {
		c.JSON(http.StatusForbidden, gin.H{"error": "L'utilisateur n'est pas participant à cette tombola"})
		return
	}

	// Vérifier si un gagnant a déjà été tiré
	if !tombola.Drawn {
		c.JSON(http.StatusOK, gin.H{
			"is_winner": false,
			"prize": nil,
			"message": "Le tirage n'a pas encore eu lieu. Veuillez revenir plus tard.",
		})
		return
	}

	// Vérifier si l'utilisateur est le gagnant
	isWinner := tombola.WinnerID != nil && *tombola.WinnerID == uint(userID)
	prize := ""
	if isWinner {
		prize = tombola.Prizes
	}

	c.JSON(http.StatusOK, gin.H{
		"is_winner": isWinner,
		"prize": prize,
		"is_drawn": tombola.Drawn,
		"message": func() string {
			if !tombola.Drawn {
				return "Le tirage n'a pas encore eu lieu. Veuillez revenir plus tard."
			}
			if isWinner {
				return "Félicitations ! Vous avez gagné."
			}
			return "Désolé, vous n'avez pas gagné cette fois-ci."
		}(),
	})
}

// AddPrizeToTombola godoc
// @Summary Add a prize to a tombola
// @Description Add a prize to a tombola
// @ID add-prize-to-tombola
// @Accept json
// @Produce json
// @Param kermesseId path int true "Kermesse ID"
// @Param request body struct{ Prize string `json:"prize" binding:"required"` } true "Prize Request"
// @Success 200 {object} models.JSONResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /tombola/{kermesseId}/prize [put]
func AddPrizeToTombola(c *gin.Context) {
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de kermesse invalide"})
		return
	}

	var req struct {
		Prize string `json:"prize" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Récupérer la tombola associée à la kermesse
	var tombola models.Tombola
	if err := database.DB.Where("kermesse_id = ?", kermesseID).First(&tombola).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tombola non trouvée pour cette kermesse"})
		return
	}

	tombola.Prizes = req.Prize
	if err := database.DB.Save(&tombola).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour de la tombola"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Prix ajouté avec succès"})
}
