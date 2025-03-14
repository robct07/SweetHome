import SwiftUI

struct DeviceConnectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    @State private var discoveredDevices: [PrinterDevice] = []
    @State private var selectedDevice: PrinterDevice?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if isScanning {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("Scanning for devices...")
                        }
                    } else if discoveredDevices.isEmpty {
                        Text("No devices found")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("Available Devices")
                }
                
                ForEach(discoveredDevices) { device in
                    Button {
                        selectedDevice = device
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                    .font(.headline)
                                Text(device.id)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedDevice?.id == device.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        startScanning()
                    } label: {
                        Label("Scan for Devices", systemImage: "arrow.clockwise")
                    }
                }
            }
            .navigationTitle("Connect Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startScanning() {
        isScanning = true
        // 模拟设备扫描
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            discoveredDevices = [
                PrinterDevice(name: "Printer 1", id: "PRINTER001"),
                PrinterDevice(name: "Printer 2", id: "PRINTER002"),
                PrinterDevice(name: "Printer 3", id: "PRINTER003")
            ]
            isScanning = false
        }
    }
}

struct PrinterDevice: Identifiable {
    let name: String
    let id: String
}

#Preview {
    DeviceConnectionView()
}
//
//  DeviceConnectionView.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/27/25.
//

