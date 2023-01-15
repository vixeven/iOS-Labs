//  ContentView.swift
//
//  Created by Victor Șaptefrați on 13.01.2023.

import SwiftUI

struct ContentView: View {
    @ObservedObject private var progressOverlay = ProgressOverlay()
    
    var body: some View {
        VStack {
            Button(action: {
                self.progressOverlay.start()
            }) {
                Text("START")
            }
            .disabled(progressOverlay.taskRunning)
        }
        .overlay(progressOverlay.taskRunning ? progressOverlay.body : nil)
    }
}

class ProgressOverlay: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var taskRunning: Bool = false
    @Published var paused: Bool = false
    
    func start() {
        taskRunning = true

        for i in Int(progress * 300)...300 {
            DispatchQueue.main.asyncAfter(deadline: .now() - progress + Double(i)/300) {
                if !self.paused {
                    let newProgress = Double(i) / 300.0
                    self.progress = newProgress
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() - progress + 1.2) {
            if !self.paused {
                self.stop()
            }
        }
    }
    
    func stop() {
        taskRunning = false
        self.reset()
    }
    
    func pause() {
        paused = true
    }
    
    func resume() {
        paused = false
        self.start();
    }
    
    func reset() {
        progress = 0;
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(Int(progress * 100))%").font(.title)
                
                Spacer()
                
                if taskRunning {
                    if paused {
                        Button(action: { self.resume() }) {
                            Text("Resume")
                        }
                    } else {
                        Button(action: { self.pause() }) {
                            Text("Pause")
                        }
                    }
                }
            }
            .padding()
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: (UIScreen.main.bounds.width - 40) * CGFloat(progress), height: 20)
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 20)
            .padding()
            
            HStack {
                Spacer()
                
                if taskRunning {
                    Button(action: {
                        self.stop()
                    }) {
                        Text("Stop")
                    }
                }
                Button(action: {
                    self.reset()
                }) {
                    Text("Reset")
                }
                .disabled(!taskRunning)
            }
            .padding()
        }
        .background(Color.gray.opacity(0.3))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .opacity(taskRunning ? 1 : 0)
    }
}
