package models

type Kermesse struct {
	Base
	Name           string     `json:"name" gorm:"not null" binding:"required"`
	Organizers     []User     `json:"organizers" gorm:"many2many:kermesse_organizers;"`
	Participants   []User     `json:"participants" gorm:"many2many:kermesse_participants;"`
	Activities     []Activity `json:"activities" gorm:"foreignKey:KermesseID"`
	TombolaPrizes  []Stock    `json:"tombola_prizes" gorm:"foreignKey:KermesseID"`
	SchoolID       uint       `json:"school_id" gorm:"not null"`
	School         School     `json:"school" gorm:"foreignKey:SchoolID"`
	InvitationCode string     `json:"invitation_code"`
}
