//
//  AiraView.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import SwiftUI

struct AriaView: View {
    @State var prompt: String?
    @State private var viewModel = AriaViewModel(voice: VoiceCaptureService())
    @State private var isAnimating = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color.ariaBackground
                    .ignoresSafeArea()
                ZStack {
                    Capsule()
                        .fill(!viewModel.isListening ? GetColor.ariaSurface : GetColor.ariaAccent)
                        .shadow(color: GetColor.ariaWarm, radius: 20)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                if viewModel.isListening {
                                    viewModel.stopListening()
                                } else {
                                    viewModel.startListening()
                                    
                                }
                            }
                        }
                    
                    VStack {
                        Text("Hello,\nI'm Aria")
                            .amountStyle(fontSize: FontT.title)
                            .foregroundStyle(GetColor.ariaWarm)
                        Spacer()
                        if !viewModel.isListening {
                            Image(systemName: "microphone.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65, height: 65)
                                .foregroundStyle(GetColor.ariaAccent)
                        }
                    }
                    .padding(.vertical, 60)
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: 210, maxHeight: 290)
                
                if viewModel.eventSaved {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(GetColor.ariaWarm) // Or a custom green if you have one
                        Text("Saved to Calendar")
                            .primaryStyle(fontSize: FontT.secondary)
                            .foregroundStyle(GetColor.ariaWarm)
                    }
                } else if let error = viewModel.errorMsg {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(GetColor.ariaWarm)
                        
                        Text(error)
                            .primaryStyle(fontSize: FontT.secondary)
                            .foregroundStyle(GetColor.ariaWarm)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                } else if viewModel.isListening {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(GetColor.ariaBackground)
                                .frame(width: 10, height: 10)
                                .scaleEffect(isAnimating ? 1.4 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.3)
                                    .repeatForever()
                                    .delay(Double(index) * 0.4),
                                    value: isAnimating
                                )
                        }
                    }
                }
                VStack {
                    ToolBarView(events: viewModel.todaysEvents)
                    Spacer()
                    
                    Spacer().frame(height: 130)
                    
                    TextField("Aria: Any new events to add?",
                              text: $viewModel.transcribedText)
                    .font(.system(size: FontT.secondary + 3, weight: .semibold, design: .serif))
                    .foregroundStyle(.ariaSurface)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(.regularMaterial)
                    .background(GetColor.ariaSurface.opacity(0.5))
                    .clipShape(.capsule)
                    .overlay {
                        HStack{
                            Spacer()
                            Button{
                                viewModel.submitText()
                                viewModel.transcribedText = ""
                            } label: {
                                Image(systemName: "pointer.arrow.ipad")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .padding()
                            .disabled(viewModel.isProcessing)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: viewModel.isListening) { _, listening in
                isAnimating = listening
            }
            .task {
                viewModel.fetchTodaysEvents()
            }
        }
    }
}

#Preview {
    AriaView(prompt: "")
}
