package models

type Kermesse struct {
	Base
	Name          string     `json:"name" gorm:"not null" binding:"required"`
	Organizers    []User     `json:"organizers" gorm:"many2many:kermesse_organizers;"`
	Activities    []Activity `json:"activities" gorm:"foreignKey:KermesseID"`
	Participants  []User     `json:"participants" gorm:"many2many:kermesse_participants;"`
	TombolaPrizes []Stock    `json:"tombola_prizes" gorm:"foreignKey:KermesseID"`
}
