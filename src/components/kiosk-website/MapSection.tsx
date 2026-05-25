import { useState, useEffect, useRef } from 'react';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { mapLocations } from './mapConfig';
import './MapSection.css';

export default function MapSection() {
  const [selectedLocation, setSelectedLocation] = useState(0);
  const mapRef = useRef<HTMLDivElement>(null);

  const mapInstanceRef = useRef<google.maps.Map | null>(null);
  const markerRef = useRef<google.maps.marker.AdvancedMarkerElement | null>(null);
  const markerListenerRef = useRef<google.maps.MapsEventListener | null>(null);
  
  useEffect(() => {
    const apiKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;
    
    if (!apiKey) {
      console.error('Google Maps API key is not configured');
      return;
    }

    const initMap = async () => {
      try {
        // Set API options before loading any libraries
        setOptions({
          key: apiKey,
          v: 'weekly'
        });

        // Import required libraries
        const { Map } = await importLibrary('maps');
        const { AdvancedMarkerElement } = await importLibrary('marker');

        if (mapRef.current && !mapInstanceRef.current) {
          const location = mapLocations[selectedLocation];
          
          // Initialize the map with mapId (required for AdvancedMarkerElement)
          mapInstanceRef.current = new Map(mapRef.current, {
            center: { lat: location.lat, lng: location.lng },
            zoom: 15,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: true,
            mapId: 'DEMO_MAP_ID', // Required for AdvancedMarkerElement
          });

          // Add marker using AdvancedMarkerElement
          markerRef.current = new AdvancedMarkerElement({
            position: { lat: location.lat, lng: location.lng },
            map: mapInstanceRef.current,
            title: location.title,
          });

          // Add click listener to marker to open Google Maps
          markerListenerRef.current = markerRef.current.addListener('click', () => {
            const currentLocation = mapLocations[selectedLocation];
            const googleMapsUrl = `https://www.google.com/maps/search/?api=1&query=${currentLocation.lat},${currentLocation.lng}`;
            window.open(googleMapsUrl, '_blank');
          });
        }
      } catch (error) {
        console.error('Error loading Google Maps:', error);
      }
    };

    initMap();
  }, []);

  // Update map when location changes
  useEffect(() => {
    if (mapInstanceRef.current && markerRef.current) {
      const location = mapLocations[selectedLocation];
      const newPosition = { lat: location.lat, lng: location.lng };
      
      mapInstanceRef.current.setCenter(newPosition);
      markerRef.current.position = newPosition;
      markerRef.current.title = location.title;

      // Remove old click listener and add new one with updated location
      if (markerListenerRef.current) {
        markerListenerRef.current.remove();
      }
      markerListenerRef.current = markerRef.current.addListener('click', () => {
        const googleMapsUrl = `https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}`;
        window.open(googleMapsUrl, '_blank');
      });
    }
  }, [selectedLocation]);

  return (
    <div className="map-section">
      {/* Location selector */}
      <div className="location-selector">
        {mapLocations.map((location, index) => (
          <button
            key={location.id}
            className={`location-btn ${selectedLocation === index ? 'active' : ''}`}
            onClick={() => setSelectedLocation(index)}
          >
            {location.title}
          </button>
        ))}
      </div>

      {/* Google Maps container */}
      <div className="map-container">
        <div ref={mapRef} className="google-map" />
      </div>

    </div>
  );
}
