//
//  CalendarService.swift
//  rufus
//
//  Created by AI Assistant on 2025-08-10.
//

import Foundation
import EventKit
import GoogleSignIn
import Combine

// MARK: - Calendar Event Model
struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let url: URL?
    let isAllDay: Bool
    let source: CalendarSource
}

enum CalendarSource: String, CaseIterable {
    case apple = "Apple Calendar"
    case google = "Google Calendar"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Calendar Service
@MainActor
class CalendarService: ObservableObject {
    @Published var calendarEvents: [CalendarEvent] = []
    @Published var hasCalendarAccess = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkCalendarAccess()
    }
    
    // MARK: - Calendar Permissions
    func checkCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized, .fullAccess:
            hasCalendarAccess = true
            loadAppleCalendarEvents()
        case .restricted, .denied:
            hasCalendarAccess = false
            errorMessage = "Calendar access denied. Please enable in Settings."
        case .notDetermined, .writeOnly:
            requestCalendarPermission()
        @unknown default:
            hasCalendarAccess = false
            errorMessage = "Unknown calendar permission status."
        }
    }
    
    func requestCalendarPermission() {
        Task {
            do {
                if #available(iOS 17.0, *) {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    await MainActor.run {
                        self.hasCalendarAccess = granted
                        if granted {
                            self.loadAppleCalendarEvents()
                        } else {
                            self.errorMessage = "Calendar access was denied."
                        }
                    }
                } else {
                    // For iOS 16 and earlier
                    let granted = try await eventStore.requestAccess(to: .event)
                    await MainActor.run {
                        self.hasCalendarAccess = granted
                        if granted {
                            self.loadAppleCalendarEvents()
                        } else {
                            self.errorMessage = "Calendar access was denied."
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to request calendar permission: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Apple Calendar Integration
    func loadAppleCalendarEvents() {
        guard hasCalendarAccess else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let calendars = eventStore.calendars(for: .event)
                let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                let endDate = Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
                
                let predicate = eventStore.predicateForEvents(
                    withStart: startDate,
                    end: endDate,
                    calendars: calendars
                )
                
                let events = eventStore.events(matching: predicate)
                
                let calendarEvents = events.map { event in
                    CalendarEvent(
                        title: event.title ?? "Untitled Event",
                        startDate: event.startDate,
                        endDate: event.endDate,
                        location: event.location,
                        notes: event.notes,
                        url: event.url,
                        isAllDay: event.isAllDay,
                        source: .apple
                    )
                }
                
                await MainActor.run {
                    self.calendarEvents = calendarEvents
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load calendar events: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Google Calendar Integration
    func loadGoogleCalendarEvents() {
        guard GIDSignIn.sharedInstance.currentUser != nil else {
            errorMessage = "Please sign in with Google first."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            // This is a placeholder for Google Calendar API integration
            // You would need to implement the actual Google Calendar API calls here
            // For now, we'll just clear any existing Google events
            
            await MainActor.run {
                // Remove existing Google events and keep Apple events
                self.calendarEvents = self.calendarEvents.filter { $0.source == .apple }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Refresh All Calendars
    func refreshAllCalendars() {
        errorMessage = nil
        
        if hasCalendarAccess {
            loadAppleCalendarEvents()
        }
        
        if GIDSignIn.sharedInstance.currentUser != nil {
            loadGoogleCalendarEvents()
        }
    }
    
    // MARK: - Event Creation
    func createEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false) {
        guard hasCalendarAccess else {
            errorMessage = "Calendar access is required to create events."
            return
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            loadAppleCalendarEvents() // Refresh events
        } catch {
            errorMessage = "Failed to create event: \(error.localizedDescription)"
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255))
    }
}
