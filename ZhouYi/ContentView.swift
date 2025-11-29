import SwiftUI

struct ContentView: View {
    @State private var hexagram: Hexagram?
    @State private var lines: [Int] = []
    @State private var showResult = false
    @State private var isDivining = false
    @State private var currentTossingLine = -1 // -1: not tossing, 0-5: tossing for that line
    @State private var showThinking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("易經卜卦")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                    .foregroundColor(.accentColor)
                
                Button(action: startDivination) {
                    Text(isDivining ? "卜卦中..." : "誠心卜卦")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isDivining ? Color.gray : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(isDivining)
                
                // Hexagram Lines Display Area
                VStack(spacing: 8) {
                    // Display lines from top (6) to bottom (1)
                    // But we generate them bottom (1) to top (6)
                    // So we reverse the array for display
                    ForEach((0..<6).reversed(), id: \.self) { index in
                        if index < lines.count {
                            // Line already generated
                            HexagramLineView(value: lines[index])
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else if index == lines.count && currentTossingLine != -1 {
                            // Currently tossing for this line
                            CoinTossView()
                        } else {
                            // Placeholder or empty space
                            Color.clear.frame(height: 12).frame(width: 200)
                        }
                    }
                }
                .frame(height: 200) // Fixed height to prevent jumping
                .padding(.vertical, 10)
                
                if showThinking {
                    Text("思考中...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
                
                if showResult, let hexagram = hexagram {
                    VStack(spacing: 20) {
                        Text(hexagram.name)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        // Swapped Order: Judgment first, then Explanation
                        VStack(alignment: .leading, spacing: 10) {
                            Text("【卦辭】")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            Text(hexagram.judgment)
                                .font(.body)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("【白話解讀】")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            Text(hexagram.explanation)
                                .font(.body)
                        }
                    }
                    .padding()
                    .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func startDivination() {
        guard !isDivining else { return }
        
        // Reset state
        isDivining = true
        showResult = false
        showThinking = false
        hexagram = nil
        lines = []
        currentTossingLine = -1
        
        // Start the sequence
        divineNextLine(lineIndex: 0)
    }
    
    private func divineNextLine(lineIndex: Int) {
        if lineIndex >= 6 {
            // All lines generated
            finishDivination()
            return
        }
        
        // Start tossing animation for this line
        currentTossingLine = lineIndex
        
        // Wait for animation (e.g., 1.5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Generate line value
            let newLine = generateLine()
            withAnimation {
                self.lines.append(newLine)
                self.currentTossingLine = -1
            }
            
            // Proceed to next line after a short pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                divineNextLine(lineIndex: lineIndex + 1)
            }
        }
    }
    
    private func finishDivination() {
        // Show "Thinking..."
        withAnimation {
            showThinking = true
        }
        
        // Wait for "Thinking" (e.g., 2 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Calculate Hexagram
            let binaryString = lines.map { ($0 % 2 != 0) ? "1" : "0" }.joined()
            
            if let result = HexagramData.data[binaryString] {
                self.hexagram = result
                withAnimation {
                    self.showThinking = false
                    self.showResult = true
                }
            }
            self.isDivining = false
        }
    }
    
    private func generateLine() -> Int {
        let coin1 = Int.random(in: 2...3)
        let coin2 = Int.random(in: 2...3)
        let coin3 = Int.random(in: 2...3)
        return coin1 + coin2 + coin3
    }
}

struct HexagramLineView: View {
    let value: Int
    
    var body: some View {
        let isYang = (value % 2 != 0)
        let isMoving = (value == 6 || value == 9)
        let color: Color = isMoving ? .red : Color("HexColor")
        
        HStack(spacing: 20) {
            if isYang {
                Rectangle()
                    .fill(color)
                    .frame(height: 12)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(height: 12)
                Rectangle()
                    .fill(color)
                    .frame(height: 12)
            }
        }
        .frame(width: 200)
    }
}

struct CoinTossView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<3) { _ in
                Circle()
                    .strokeBorder(Color("HexColor"), lineWidth: 2)
                    .background(Circle().fill(Color("HexColor").opacity(0.2)))
                    .frame(width: 30, height: 30)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 1, y: 0, z: 0))
            }
        }
        .frame(width: 200, height: 12)
        .onAppear {
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    ContentView()
}
