// Configuration for map locations
// Using coordinates (lat, lng) for precise location markers
export interface MarkerLocation {
  id: number;
  title: string;
  lat: number;
  lng: number;
}

export const mapLocations: MarkerLocation[] = [
  {
    id: 1,
    title: "City Center",
    lat: 30.080834271607593,
    lng: 31.364956750887245
  },
  {
    id: 2,
    title: "City Stars Mall",
    lat: 30.073520403660975,
    lng: 31.34726801239841
  },
  {
    id: 3,
    title: "Mall of Egypt",
    lat: 29.97317364046132,
    lng: 31.015265549124234
  },
  {
    id: 4,
    title: "Cairo Festival",
    lat: 30.02903123835634,
    lng: 31.407714842726516
  },
  {
    id: 5,
    title: "Arkan Plaza",
    lat: 30.020571468458463,
    lng: 31.00377365526882
  },
  {
    id: 6,
    title: "Mall of Arabia",
    lat: 30.00667873307919,
    lng: 30.97536331006401
  }
];
