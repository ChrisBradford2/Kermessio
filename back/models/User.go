package models

type User struct {
	Base
	Username               string     `gorm:"unique" json:"username" binding:"required" example:"jdoe"`
	LastName               string     `json:"last_name" example:"Doe"`
	FirstName              string     `json:"first_name" example:"John"`
	Email                  string     `gorm:"unique;default:null" json:"email" binding:"required" example:"john.doe@example.com"`
	Password               string     `gorm:"not null" json:"password" binding:"required" example:"password"`
	Role                   string     `json:"role" gorm:"not null" binding:"required" example:"user"`
	Points                 int        `json:"points" gorm:"default:0"`
	ParentID               *uint      `gorm:"default:null"`        // If the user is a child, this will reference their parent's ID
	Parent                 *User      `gorm:"foreignKey:ParentID"` // Relationship to parent
	Tokens                 int64      `json:"tokens" gorm:"default:0"`
	Activities             []Activity `json:"activities" gorm:"foreignKey:BoothHolderID"`
	Stocks                 []Stock    `json:"stocks" gorm:"foreignKey:BoothHolderID"`
	Purchases              []Purchase `json:"purchases" gorm:"foreignKey:UserID"`
	KermessesAsOrganizer   []Kermesse `gorm:"many2many:kermesse_organizers;"`
	KermessesAsParticipant []Kermesse `gorm:"many2many:kermesse_participants;"`
	PositionX              int        `json:"position_x" gorm:"default:0"`
	PositionY              int        `json:"position_y" gorm:"default:0"`
	SchoolID               uint       `json:"school_id" gorm:"not null"` // Clé étrangère vers l'école
	School                 School     `json:"school" gorm:"foreignKey:SchoolID"`
}

type UserRegister struct {
	Username  string `json:"username" binding:"required" example:"jdoe"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	Email     string `gorm:"unique;default:null" json:"email" example:"john.doe@example.com"`
	Password  string `json:"password" binding:"required" example:"password"`
	Role      string `json:"role" binding:"required" example:"parent"`
	SchoolID  uint   `json:"school_id" gorm:"not null"` // Clé étrangère vers l'école
	School    School `json:"school" gorm:"foreignKey:SchoolID"`
}

type UserRegisterResponse struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}

type UserLogin struct {
	Username string `json:"username" binding:"required" example:"jdoe"`
	Password string `json:"password" binding:"required" example:"password"`
}

type ChildRequest struct {
	Username  string `json:"username" binding:"required" example:"jdoe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	Password  string `json:"password" binding:"required,min=6" example:"password"`
}

type ChildRequestResponse struct {
	Message string `json:"message"`
	Child   string `json:"child"`
}

// PublicUser omits sensitive data from user model
type PublicUser struct {
	ID        uint   `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
}

type PublicChild struct {
	Base
	Username string `json:"username"`
	Tokens   int    `json:"tokens"`
	Points   int    `json:"points"`
}

type TokensRequest struct {
	Tokens int `json:"tokens" binding:"required"`
}
