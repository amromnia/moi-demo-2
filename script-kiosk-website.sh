#!/bin/bash
set -euo pipefail

# =============================================================================
# File contents (edit these blocks to change what gets written)
# =============================================================================

# -----------------------------------------------------------------------------
# New contents for src/mapConfig.ts (always overwritten)
# -----------------------------------------------------------------------------
NEW_MAPCONFIG_CONTENT=$(cat << 'EOF_NEW_MAPCONFIG'

// Configuration for map locations
// Using coordinates (lat, lng) for precise location markers
export interface MarkerLocation {
  id: number;
  title: string;
  lat: number;
  lng: number;
  kioskLocation?: string;
  inspectionLocation?: string;
}

export const mapLocations: MarkerLocation[] = [
  {
    id: 1,
    title: "City Center Almaza",
    lat: 30.080834271607593,
    lng: 31.364956750887245,
    kioskLocation: "الدور الأول",
  },
  {
    id: 2,
    title: "City Stars Mall",
    lat: 30.073520403660975,
    lng: 31.34726801239841,
    kioskLocation: "الدور الأرضي – المرحلة الثانية",
    inspectionLocation: "يتم إجراء الفحص الفني للمركبة في الجراج الداخلي دور -3 عند N15"
  },
  {
    id: 3,
    title: "Mall of Egypt",
    lat: 29.97317364046132,
    lng: 31.015265549124234,
    kioskLocation: "الدور الثاني",
  },
  {
    id: 4,
    title: "Cairo Festival",
    lat: 30.02903123835634,
    lng: 31.407714842726516,
    kioskLocation: "موقف P2 – بوابة K",
    inspectionLocation: "يتم إجراء الفحص الفني للمركبة في الجراج الخارجي عند بوابة 4"
  },
  {
    id: 5,
    title: "Arkan Plaza",
    lat: 30.020571468458463,
    lng: 31.00377365526882,
    kioskLocation: "عند المصعد – تحت دور السينما",
  },
  {
    id: 6,
    title: "Mall of Arabia",
    lat: 30.00667873307919,
    lng: 30.97536331006401,
    kioskLocation: "عند بوابة 22",
    inspectionLocation: "يتم إجراء الفحص الفني للمركبة في الجراج الخارجي عند بوابة 22"
  },
  {
    id: 7,
    title: "مركز شباب الجزيرة",
    lat: 30.04981967909986,
    lng: 31.219653337428845,
  },
  {
    id: 8,
    title: "نادي سبورتنج ش أبوقير",
    lat: 31.212862239066837,
    lng: 29.933759365636792,
  },
  {
    id: 9,
    title: "نادي هليوبوليس",
    lat: 30.09610632032502,
    lng: 31.31552050476953,
  },
  {
    id: 10,
    title: "نادي المعادي",
    lat: 29.965768427331007,
    lng: 31.263058104382026,
  },
  {
    id: 11,
    title: "سيارة الخدمة الذاتية المتنقله بالساحل الشمالي",
    lat: 30.956436952433652,
    lng: 29.53677919759234,
  }
];


EOF_NEW_MAPCONFIG
)

# -----------------------------------------------------------------------------
# Expected current contents of src/MapSection.tsx
# (we only overwrite the file if its current contents match this EXACTLY)
# -----------------------------------------------------------------------------
EXPECTED_MAPSECTION_CONTENT=$(cat << 'EOF_EXPECTED_MAPSECTION'

import { useState, useEffect, useRef } from 'react';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { mapLocations } from './mapConfig';
import './MapSection.css';

export default function MapSection() {
  const [selectedLocation, setSelectedLocation] = useState(0);
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markerRef = useRef<any>(null);
  const markerListenerRef = useRef<any>(null);

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

      {/* Kiosk location info */}
      <div className="inspection-info kiosk-info">
        <h3 className="inspection-title">موقع الكشك داخل المول</h3>
        {mapLocations[selectedLocation].kioskLocation
          ? <p className="inspection-text">{mapLocations[selectedLocation].kioskLocation}</p>
          : <p className="inspection-text inspection-text--empty">لا يوجد</p>
        }
      </div>

      {/* Inspection location info */}
      <div className="inspection-info">
        <h3 className="inspection-title">مكان فحص المركبة</h3>
        {mapLocations[selectedLocation].inspectionLocation
          ? <p className="inspection-text">{mapLocations[selectedLocation].inspectionLocation}</p>
          : <p className="inspection-text inspection-text--empty">لا يوجد</p>
        }
      </div>

    </div>
  );
}

EOF_EXPECTED_MAPSECTION
)

# -----------------------------------------------------------------------------
# New contents for src/MapSection.tsx (written only if expected matches)
# -----------------------------------------------------------------------------
NEW_MAPSECTION_CONTENT=$(cat << 'EOF_NEW_MAPSECTION'

import { useState, useEffect, useRef } from 'react';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { mapLocations } from './mapConfig';
import './MapSection.css';

export default function MapSection() {
  const [selectedLocation, setSelectedLocation] = useState(0);
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markerRef = useRef<any>(null);
  const markerListenerRef = useRef<any>(null);

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

      {/* Kiosk location info */}
      <div className="inspection-info kiosk-info">
        <h3 className="inspection-title">موقع الكشك</h3>
        {mapLocations[selectedLocation].kioskLocation
          ? <p className="inspection-text">{mapLocations[selectedLocation].kioskLocation}</p>
          : <p className="inspection-text inspection-text--empty">لا يوجد</p>
        }
      </div>

      {/* Inspection location info */}
      <div className="inspection-info">
        <h3 className="inspection-title">مكان فحص المركبة</h3>
        {mapLocations[selectedLocation].inspectionLocation
          ? <p className="inspection-text">{mapLocations[selectedLocation].inspectionLocation}</p>
          : <p className="inspection-text inspection-text--empty">لا يوجد</p>
        }
      </div>

    </div>
  );
}

EOF_NEW_MAPSECTION
)


# =============================================================================
# Script logic — does not normally need editing
# =============================================================================

MAPCONFIG_PATH="src/mapConfig.ts"
MAPSECTION_PATH="src/MapSection.tsx"

echo "=== Starting update ==="
echo "Current directory: $(pwd)"

# -----------------------------------------------------------------------------
# Pre-flight checks: make sure we are in the project root and target files exist
# -----------------------------------------------------------------------------
echo ""
echo "Verifying we are in the project root..."

MISSING=0
if [ ! -f "package.json" ]; then
  echo "  ERROR: package.json not found in current directory."
  MISSING=1
fi
if [ ! -f "$MAPCONFIG_PATH" ]; then
  echo "  ERROR: $MAPCONFIG_PATH not found."
  MISSING=1
fi
if [ ! -f "$MAPSECTION_PATH" ]; then
  echo "  ERROR: $MAPSECTION_PATH not found."
  MISSING=1
fi

if [ "$MISSING" -ne 0 ]; then
  echo ""
  echo "Aborting: you must run this script from the kiosk-website project root"
  echo "(the folder that contains package.json and the src/ folder)."
  echo "No files have been changed."
  exit 1
fi

echo "  OK — required files found."

# Note: the heredoc variables above start and end with a blank line for
# readability. Strip the leading blank line so the written files start
# directly with their real first line (no leading blank line).
NEW_MAPCONFIG_CONTENT="${NEW_MAPCONFIG_CONTENT#$'\n'}"
EXPECTED_MAPSECTION_CONTENT="${EXPECTED_MAPSECTION_CONTENT#$'\n'}"
NEW_MAPSECTION_CONTENT="${NEW_MAPSECTION_CONTENT#$'\n'}"

# -----------------------------------------------------------------------------
# 1. Always overwrite src/mapConfig.ts
# -----------------------------------------------------------------------------
echo ""
echo "Writing $MAPCONFIG_PATH ..."
printf '%s\n' "$NEW_MAPCONFIG_CONTENT" > "$MAPCONFIG_PATH"
echo "  Done."

# -----------------------------------------------------------------------------
# 2. Conditionally overwrite src/MapSection.tsx
#    Only if its current content matches EXPECTED_MAPSECTION_CONTENT,
#    ignoring ALL whitespace (indentation, blank lines, line endings, spaces,
#    tabs, etc.). We compare the two with every whitespace character stripped
#    out, so only the raw non-whitespace text matters.
# -----------------------------------------------------------------------------
echo ""
echo "Checking $MAPSECTION_PATH against expected version (whitespace-insensitive)..."

expected_normalized=$(printf '%s' "$EXPECTED_MAPSECTION_CONTENT" | tr -d '[:space:]')
actual_normalized=$(tr -d '[:space:]' < "$MAPSECTION_PATH")

if [ "$expected_normalized" = "$actual_normalized" ]; then
  echo "  Match. Writing new version..."
  printf '%s\n' "$NEW_MAPSECTION_CONTENT" > "$MAPSECTION_PATH"
  echo "  Done."
else
  echo "  No match — leaving $MAPSECTION_PATH untouched."
fi

# -----------------------------------------------------------------------------
# 3. Build and restart
#
# NOTE: stdin is redirected from /dev/null for these commands.
# When this script is run via `curl ... | bash`, the script itself is being
# read from stdin (the pipe). Any child process that also reads from stdin
# (npm / vite / esbuild / pm2) will consume the remaining bytes of the
# script, causing bash to silently hit EOF and skip the rest. Detaching
# stdin from these commands prevents that.
# -----------------------------------------------------------------------------
echo ""
echo "=== Running npm run build ==="
npm run build < /dev/null

echo ""
echo "=== Restarting pm2 ==="
pm2 restart all < /dev/null

echo ""
echo "=== Update complete ==="
