package models

type Tombola struct {
	Base
	KermesseID   uint   `json:"kermesse_id" gorm:"not null"`                         // Référence à la kermesse
	Prizes       string `json:"prizes" gorm:"not null;default:'À définir'"`          // Liste des lots en tant que texte
	Drawn        bool   `json:"drawn" gorm:"default:false"`                          // Indicateur si le tirage a eu lieu
	WinnerID     *uint  `json:"winner_id" gorm:"default:null"`                       // Référence vers l'utilisateur gagnant
	Winner       *User  `json:"winner" gorm:"foreignKey:WinnerID"`                   // Relation avec l'utilisateur gagnant
	Participants []User `json:"participants" gorm:"many2many:tombola_participants;"` // Liste des enfants participants
}
