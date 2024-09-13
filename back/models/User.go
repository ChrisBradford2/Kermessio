package models

type User struct {
	Base
	Username  string `gorm:"unique" json:"username" binding:"required" example:"jdoe"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	Email     string `gorm:"unique" json:"email" binding:"required" example:"john.doe@exmple.com"`
	Password  string `gorm:"not null" json:"password" binding:"required" example:"password"`
	Role      string `json:"role" gorm:"not null" binding:"required" example:"user"`
	ParentID  *uint  `gorm:"default:null"`        // If the user is a child, this will reference their parent's ID
	Parent    *User  `gorm:"foreignKey:ParentID"` // Relationship to parent
	Tokens    int    `json:"tokens" gorm:"default:0"`
}

type UserRegister struct {
	Username  string `json:"username" binding:"required" example:"jdoe"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	Email     string `json:"email" binding:"required" example:"john.doe@exmple.com"`
	Password  string `json:"password" binding:"required" example:"password"`
	Role      string `json:"role" binding:"required" example:"parent"`
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
	Username string `json:"username" binding:"required" example:"jdoe"`
	Password string `json:"password" binding:"required,min=6" example:"password"`
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
