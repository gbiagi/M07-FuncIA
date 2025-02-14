// Defineix les eines/funcions que hi ha disponibles a flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          "Dibuixa un cercle amb un radi determinat, si falta el radi posar-ne un de 10 per defecte, si el radi ha de ser aletori posar-ne un aleatori entre 10 i 25",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number"},
          "y": {"type": "number"},
          "radius": {"type": "number"},
          "color": {"type": "string"}
        },
        "required": ["x", "y", "radius", "color"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description":
          "Dibuixa una línia entre dos punts, si no s'especifica la posició escull els punts aleatòries entre x=10, y=10 i x=100, y=100",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "color": {"type": "string"},
          "thickness": {"type": "number"}
        },
        "required": ["startX", "startY", "endX", "endY", "color", "thickness"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description":
          "Dibuixa un rectangle definit per les coordenades superior-esquerra i inferior-dreta",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "color": {"type": "string"},
          "thickness": {"type": "number"}
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY", "color", "thickness"]
      }
    }
  }
];
