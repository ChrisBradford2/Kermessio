package config

// Define the different roles in the system
const (
	RoleParent      = "parent"
	RoleChild       = "child"
	RoleBoothHolder = "booth_holder"
	RoleOrganizer   = "organizer"
)

// RolePermissions holds the permissions for each role
type RolePermissions struct {
	CanBuyTokens               bool
	CanDistributeTokens        bool
	CanViewChildrenStats       bool
	CanManageStands            bool
	CanParticipateInActivities bool
	CanManageKermesse          bool
	CanManageTombola           bool
	CanSendChatMessages        bool
}

// GetRolePermissions returns the permissions for a given role
func GetRolePermissions(role string) RolePermissions {
	switch role {
	case RoleParent:
		return RolePermissions{
			CanBuyTokens:               true,
			CanDistributeTokens:        true,
			CanViewChildrenStats:       true,
			CanParticipateInActivities: false,
			CanManageStands:            false,
			CanManageKermesse:          false,
			CanManageTombola:           false,
			CanSendChatMessages:        false,
		}
	case RoleChild:
		return RolePermissions{
			CanBuyTokens:               false,
			CanDistributeTokens:        false,
			CanViewChildrenStats:       false,
			CanParticipateInActivities: true,
			CanManageStands:            false,
			CanManageKermesse:          false,
			CanManageTombola:           false,
			CanSendChatMessages:        false,
		}
	case RoleBoothHolder:
		return RolePermissions{
			CanBuyTokens:               false,
			CanDistributeTokens:        false,
			CanViewChildrenStats:       false,
			CanParticipateInActivities: false,
			CanManageStands:            true,
			CanManageKermesse:          false,
			CanManageTombola:           false,
			CanSendChatMessages:        true,
		}
	case RoleOrganizer:
		return RolePermissions{
			CanBuyTokens:               false,
			CanDistributeTokens:        false,
			CanViewChildrenStats:       false,
			CanParticipateInActivities: false,
			CanManageStands:            true,
			CanManageKermesse:          true,
			CanManageTombola:           true,
			CanSendChatMessages:        true,
		}
	default:
		return RolePermissions{}
	}
}

// HasPermission checks if a user has a specific permission
func (rp RolePermissions) HasPermission(permission string) bool {
	switch permission {
	case "CanBuyTokens":
		return rp.CanBuyTokens
	case "CanDistributeTokens":
		return rp.CanDistributeTokens
	case "CanViewChildrenStats":
		return rp.CanViewChildrenStats
	case "CanManageStands":
		return rp.CanManageStands
	case "CanParticipateInActivities":
		return rp.CanParticipateInActivities
	case "CanManageKermesse":
		return rp.CanManageKermesse
	case "CanManageTombola":
		return rp.CanManageTombola
	case "CanSendChatMessages":
		return rp.CanSendChatMessages
	default:
		return false
	}
}
