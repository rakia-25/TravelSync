class DashboardsController < ApplicationController
  layout "dashboard"
  require "csv"

  before_action :authenticate_user!
  before_action :set_provider      # <- Doit venir AVANT
  before_action :redirect_by_role

  def provider
    case @provider.type_provider
    when "hotelier"
      handle_hotelier_dashboard
    when "rental_agency"
      handle_rental_agency_dashboard
    when "travel_agency"
      handle_travel_agency_dashboard
    else
      redirect_to root_path, alert: "Type de prestataire non reconnu."
    end
  end

  def export_data
    case @provider.type_provider
    when "hotelier"
      export_hotels
    when "rental_agency"
      export_cars
    when "travel_agency"
      export_trips
    else
      redirect_to provider_dashboard_path, alert: "Export non disponible pour ce type de prestataire."
    end
  end

  private

  def set_provider
    @provider = current_user.provider
  end

  def redirect_by_role
    unless current_user.provider?
      redirect_to root_path, alert: "Accès réservé aux prestataires." and return
    end

    if @provider.nil?
      redirect_to new_provider_path, alert: "Complétez votre profil prestataire d'abord." and return
    end
  end

  # ==================== HOTELIER DASHBOARD ====================
  def handle_hotelier_dashboard
    @hotels = @provider.hotels.includes(:rooms)
    @total_rooms = @hotels.sum { |h| h.rooms.count }

    room_ids = @hotels.flat_map { |h| h.rooms.pluck(:id) }

    @reservations = Reservation.where(reservable_type: "Room", reservable_id: room_ids)
    @rooms = Room.includes(:hotel).where(id: room_ids).index_by(&:id)

    calculate_hotelier_metrics
    set_hotelier_period_data
    set_hotelier_recent_activities

    render "dashboards/hotelier"
  end

  def calculate_hotelier_metrics
    @total_reservations = @reservations.count
    @confirmed_reservations = @reservations.where(status: "confirmed").count
    @pending_reservations = @reservations.where(status: "pending").count
    @cancelled_reservations = @reservations.where(status: "cancelled").count

    # Revenus
    @total_revenue = @reservations.where(status: "confirmed").sum(&:total_price) || 0
    @monthly_revenue = @reservations.where(status: "confirmed")
                                    .where("created_at >= ?", 1.month.ago)
                                    .sum(&:total_price) || 0
  end

  def set_hotelier_period_data
    period = params[:period] || "week"

    @filtered_reservations = case period
                             when "month"
                               @reservations.where("created_at >= ?", 1.month.ago)
                             when "year"
                               @reservations.where("created_at >= ?", 1.year.ago)
                             else
                               @reservations.where("created_at >= ?", 1.week.ago)
                             end

    # Statistiques par hôtel
    @reserv_by_hotel = calculate_reservations_by_hotel(@filtered_reservations)

    # Taux d'occupation
    @occupancy_rate = calculate_occupancy_rate(@filtered_reservations, period)
  end

  def calculate_reservations_by_hotel(reservations)
    hotel_counts = @hotels.map { |hotel| [hotel.name, 0] }.to_h

    reservations_by_room = reservations.group(:reservable_id).count
    rooms_by_id = Room.where(id: reservations_by_room.keys)
                      .includes(:hotel)
                      .index_by(&:id)

    reservations_by_room.each do |room_id, count|
      hotel_name = rooms_by_id[room_id]&.hotel&.name
      hotel_counts[hotel_name] += count if hotel_name
    end

    hotel_counts.map { |name, count| { name: name, count: count } }
  end

  def calculate_occupancy_rate(reservations, period)
    return 0 if @total_rooms.zero?

    days_in_period = case period
                     when "month" then 30
                     when "year"  then 365
                     else 7
                     end

    total_possible_reservations = @total_rooms * days_in_period
    confirmed_reservations = reservations.where(status: "confirmed").count

    ((confirmed_reservations.to_f / total_possible_reservations) * 100).round(2)
  end

  def set_hotelier_recent_activities
    room_ids = @hotels.flat_map { |h| h.rooms.pluck(:id) }

    # Nouvelles réservations
    new_reservations = @reservations.order(created_at: :desc)
                                    .limit(3)
                                    .map do |reservation|
      {
        type: :reservation_new,
        message: "Nouvelle réservation à l'Hôtel #{@rooms[reservation.reservable_id]&.hotel&.name}",
        time: reservation.created_at,
        icon: "calendar-plus"
      }
    end

    # Réservations confirmées récemment
    confirmed_reservations = @reservations.where(status: "confirmed")
                                          .order(updated_at: :desc)
                                          .limit(3)
                                          .map do |r|
      {
        type: :reservation_confirmed,
        message: "Réservation confirmée à l'Hôtel #{r.reservable.hotel.name}",
        time: r.updated_at,
        icon: "check-circle"
      }
    end

    # Nouvelles chambres
    new_rooms = Room.where(hotel_id: @hotels.pluck(:id))
                    .order(created_at: :desc)
                    .limit(2)
                    .map do |room|
      {
        type: :room_new,
        message: "Nouvelle chambre ajoutée à l'Hôtel #{room.hotel.name}",
        time: room.created_at,
        icon: "home"
      }
    end

    @recent_activities = (new_reservations + confirmed_reservations + new_rooms)
                         .sort_by { |activity| activity[:time] }
                         .reverse
                         .take(8)
  end

  # ==================== RENTAL AGENCY DASHBOARD ====================
  def handle_rental_agency_dashboard
    @cars = @provider.cars.includes(:reservations)
    @total_cars = @cars.count

    @reservations = Reservation.includes(:reservable)
                               .where(reservable_type: "Car", reservable_id: @cars.pluck(:id))

    calculate_rental_metrics
    set_rental_period_data
    set_rental_recent_activities

    render "dashboards/rental_agency"
  end

  def calculate_rental_metrics
    @total_reservations = @reservations.count
    @confirmed_reservations = @reservations.where(status: "confirmed").count
    @pending_reservations = @reservations.where(status: "pending").count
    @cancelled_reservations = @reservations.where(status: "cancelled").count

    # Voitures disponibles
    @available_cars = @cars.where(available: "true").count
    @rented_cars = @cars.where(available: "true").count

    # Revenus
    @total_revenue = @reservations.where(status: "confirmed").sum(&:total_price) || 0
    @monthly_revenue = @reservations.where(status: "confirmed")
                                    .where("created_at >= ?", 1.month.ago)
                                    .sum(&:total_price) || 0
  end

  def set_rental_period_data
    period = params[:period] || "week"

    @filtered_reservations = case period
                             when "month"
                               @reservations.where("created_at >= ?", 1.month.ago)
                             when "year"
                               @reservations.where("created_at >= ?", 1.year.ago)
                             else
                               @reservations.where("created_at >= ?", 1.week.ago)
                             end

    # Statistiques par voiture
    @reserv_by_car = @cars.map do |car|
      {
        brand: car.brand,
        model: car.model,
        count: @filtered_reservations.where(reservable_id: car.id).count,
        revenue: @filtered_reservations.where(reservable_id: car.id, status: "confirmed")
                                       .sum(&:total_price) || 0
      }
    end.sort_by { |car| -car[:count] }
  end

  def set_rental_recent_activities
    # Nouvelles réservations
    new_reservations = @reservations.order(created_at: :desc)
                                    .limit(3)
                                    .map do |reservation|
      {
        type: :reservation_new,
        message: "Nouvelle réservation pour #{reservation.reservable.brand} #{reservation.reservable.model}",
        time: reservation.created_at,
        icon: "car"
      }
    end

    # Nouveaux véhicules
    new_cars = @cars.order(created_at: :desc)
                    .limit(2)
                    .map do |car|
      {
        type: :car_new,
        message: "Nouveau véhicule ajouté : #{car.brand} #{car.model}",
        time: car.created_at,
        icon: "plus-circle"
      }
    end
  end

  # ==================== TRAVEL AGENCY DASHBOARD ====================
  def handle_travel_agency_dashboard
    @trips = @provider.trips.includes(:reservations)
    @total_trips = @trips.count

    @reservations = Reservation.includes(:reservable)
                               .where(reservable_type: "Trip", reservable_id: @trips.pluck(:id))

    calculate_travel_metrics
    set_travel_period_data
    set_travel_recent_activities

    render "dashboards/travel_agency"
  end

  def calculate_travel_metrics
    @total_reservations = @reservations.count
    @confirmed_reservations = @reservations.where(status: "confirmed").count
    @pending_reservations = @reservations.where(status: "pending").count
    @cancelled_reservations = @reservations.where(status: "cancelled").count

    # Sans champ status sur trips, on commente ou supprime les lignes suivantes
    # @active_trips = @trips.where(status: "active").count
    # @completed_trips = @trips.where(status: "completed").count

    # Revenus
    @reservations = Reservation.where(reservable_type: "Trip", reservable_id: @trips.pluck(:id))
  end

  def set_travel_period_data
    period = params[:period] || "week"

    @filtered_reservations = case period
                             when "month"
                               @reservations.where("created_at >= ?", 1.month.ago)
                             when "year"
                               @reservations.where("created_at >= ?", 1.year.ago)
                             else
                               @reservations.where("created_at >= ?", 1.week.ago)
                             end

    @reserv_by_trip = @trips.map do |trip|
      {
        title: trip.title,
        theme: trip.theme,
        departureCity: trip.departureCity,
        destinationCity: trip.destinationCity,
        count: @filtered_reservations.where(reservable_id: trip.id).count,
        revenue: @filtered_reservations.where(reservable_id: trip.id, status: "confirmed").sum(&:total_price) || 0
      }
    end.sort_by { |trip| -trip[:count] }
  end

  def set_travel_recent_activities
    new_reservations = @reservations.order(created_at: :desc)
                                    .limit(3)
                                    .map do |reservation|
      {
        type: :reservation_new,
        message: "Nouvelle réservation pour #{reservation.reservable.title}",
        time: reservation.created_at,
        icon: "map-pin"
      }
    end

    # Comme pas de status "completed" sur trip, on peut retirer ce bloc ou l'adapter
    completed_trips = []

    new_trips = @trips.order(created_at: :desc)
                      .limit(3)
                      .map do |trip|
      {
        type: :trip_new,
        message: "Nouveau voyage ajouté : #{trip.title}",
        time: trip.created_at,
        icon: "plus-circle"
      }
    end

    @recent_activities = (new_reservations + completed_trips + new_trips)
                         .sort_by { |activity| activity[:time] }
                         .reverse
                         .take(8)
  end

  def export_trips
    @trips = @provider.trips.includes(:reservations)

    bom = "\uFEFF"
    csv_data = CSV.generate(col_sep: ";", force_quotes: true) do |csv|
      csv << ["Titre", "Thème", "Durée (jours)", "Date départ", "Date retour", "Ville départ", "Ville destination", "Prix (€)", "Réservations totales", "Réservations confirmées", "Revenus (€)"]

      @trips.each do |trip|
        reservations = Reservation.where(reservable_type: "Trip", reservable_id: trip.id)
        total_reservations = reservations.count
        confirmed_reservations = reservations.where(status: "confirmed").count
        revenue = reservations.where(status: "confirmed").sum(:total_price) || 0

        csv << [
          trip.title,
          trip.theme,
          trip.duration,
          trip.departureDate,
          trip.returnDate,
          trip.departureCity,
          trip.destinationCity,
          trip.price,
          total_reservations,
          confirmed_reservations,
          revenue
        ]
      end
    end

    send_data bom + csv_data,
              filename: "voyages-#{Date.today}.csv",
              type: "text/csv; charset=utf-8"
  end

  # ==================== EXPORT METHODS ====================
  def export_hotels
    @hotels = @provider.hotels.includes(:rooms, :reservations)

    bom = "\uFEFF"
    csv_data = CSV.generate(col_sep: ";", force_quotes: true) do |csv|
      csv << ["Nom de l'Hôtel", "Adresse", "Nombre de chambres", "Réservations totales", "Réservations confirmées", "Revenus (€)"]

      @hotels.each do |hotel|
        room_ids = hotel.rooms.pluck(:id)
        reservations = Reservation.where(reservable_type: "Room", reservable_id: room_ids)
        total_reservations = reservations.count
        confirmed_reservations = reservations.where(status: "confirmed").count
        revenue = reservations.where(status: "confirmed").sum(:total_price) || 0

        csv << [
          hotel.name,
          hotel.address,
          room_ids.size,
          total_reservations,
          confirmed_reservations,
          revenue
        ]
      end
    end

    send_data bom + csv_data,
              filename: "hotels-#{Date.today}.csv",
              type: "text/csv; charset=utf-8"
  end

  def export_cars
    @cars = @provider.cars.includes(:reservations)

    bom = "\uFEFF"
    csv_data = CSV.generate(col_sep: ";", force_quotes: true) do |csv|
      csv << ["Marque", "Modèle", "Statut", "Réservations totales", "Réservations confirmées", "Revenus (€)"]

      @cars.each do |car|
        reservations = Reservation.where(reservable_type: "Car", reservable_id: car.id)
        total_reservations = reservations.count
        confirmed_reservations = reservations.where(status: "confirmed").count
        revenue = reservations.where(status: "confirmed").sum(:total_price) || 0

        csv << [
          car.brand,
          car.model,
          car.available,
          total_reservations,
          confirmed_reservations,
          revenue
        ]
      end
    end

    send_data bom + csv_data,
              filename: "vehicules-#{Date.today}.csv",
              type: "text/csv; charset=utf-8"
  end

  def export_trips
    @trips = @provider.trips.includes(:reservations)

    bom = "\uFEFF"
    csv_data = CSV.generate(col_sep: ";", force_quotes: true) do |csv|
      csv << ["Titre", "Thème", "Durée (jours)", "Date départ", "Date retour", "Ville départ", "Ville destination", "Prix (€)", "Réservations totales", "Réservations confirmées", "Revenus (€)"]

      @trips.each do |trip|
        reservations = Reservation.where(reservable_type: "Trip", reservable_id: trip.id)
        total_reservations = reservations.count
        confirmed_reservations = reservations.where(status: "confirmed").count
        revenue = reservations.where(status: "confirmed").sum(:total_price) || 0

        csv << [
          trip.title,
          trip.theme,
          trip.duration,
          trip.departureDate,
          trip.returnDate,
          trip.departureCity,
          trip.destinationCity,
          trip.price,
          total_reservations,
          confirmed_reservations,
          revenue
        ]
      end
    end

    send_data bom + csv_data,
              filename: "voyages-#{Date.today}.csv",
              type: "text/csv; charset=utf-8"
  end
end
