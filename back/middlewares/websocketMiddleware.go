package middleware

import (
	"github.com/gorilla/websocket"
	"kermessio/database"
	"kermessio/models"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Disable cross-origin checks, should adjust for production
	},
}

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan Message)

// Message struct for incoming and outgoing messages
type Message struct {
	Sender  string `json:"sender"`
	Message string `json:"message"`
}

func HandleWebSocket(w http.ResponseWriter, r *http.Request) {
    log.Println("Attempting WebSocket upgrade...")
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Println("WebSocket upgrade error:", err)
        http.Error(w, "Could not upgrade WebSocket", http.StatusBadRequest)
        return
    }
    log.Println("WebSocket connection established")

    defer func(conn *websocket.Conn) {
        if err := conn.Close(); err != nil {
            log.Printf("Error closing connection: %v", err)
        }
    }(conn)

    clients[conn] = true

    // Ecouter les messages
    for {
        var chatMessage models.ChatMessage
        err := conn.ReadJSON(&chatMessage)
        if err != nil {
            log.Printf("WebSocket read error: %v", err)
            delete(clients, conn)
            break
        }

        // Enregistrer le message dans la base de données
        if err := database.DB.Create(&chatMessage).Error; err != nil {
            log.Printf("Error saving message: %v", err)
        }

        // Broadcast le message
        broadcastMessage := Message{
            Sender:  chatMessage.Sender.Username,
            Message: chatMessage.Message,
        }
        broadcast <- broadcastMessage
    }
}

func HandleMessages() {
	for {
		msg := <-broadcast
		for client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("Error: %v", err)
				err := client.Close()
				if err != nil {
					log.Printf("Error closing client: %v", err)
				}
				delete(clients, client)
			}
		}
	}
}
