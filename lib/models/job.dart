class Job {
  final String id;
  final String title;
  final String location;
  final String distance;
  final double distanceValue;
  final String time;
  final String price;
  final double priceValue;
  final int peopleNeeded;
  final String image;
  final String date;
  final String shift;
  final String description;
  final String address;
  final double lat;
  final double lng;

  Job({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.distanceValue,
    required this.time,
    required this.price,
    required this.priceValue,
    required this.peopleNeeded,
    required this.image,
    required this.date,
    required this.shift,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

final List<Job> dummyJobs = [
  Job(
    id: '1',
    title: 'Wedding Service',
    location: 'Bandra',
    distance: '2.3 km',
    distanceValue: 2.3,
    time: '6PM - 12AM',
    price: '₹1000',
    priceValue: 1000,
    peopleNeeded: 5,
    image: 'https://picsum.photos/seed/wedding/800/600',
    date: '2026-04-11',
    shift: 'Night',
    description:
        'High-end wedding reception catering service. Professional attire required.',
    address: 'Taj Lands End, Bandra West, Mumbai',
    lat: 19.0413,
    lng: 72.8193,
  ),
  Job(
    id: '2',
    title: 'Corporate Gala',
    location: 'Worli',
    distance: '4.5 km',
    distanceValue: 4.5,
    time: '7PM - 11PM',
    price: '₹1200',
    priceValue: 1200,
    peopleNeeded: 8,
    image: 'https://picsum.photos/seed/corporate/800/600',
    date: '2026-04-12',
    shift: 'Night',
    description:
        'Annual corporate gala dinner. Fast-paced environment with high expectations.',
    address: 'The St. Regis Mumbai, Lower Parel, Mumbai',
    lat: 18.9940,
    lng: 72.8245,
  ),
  Job(
    id: '3',
    title: 'Breakfast Catering',
    location: 'Andheri',
    distance: '5.1 km',
    distanceValue: 5.1,
    time: '7AM - 12PM',
    price: '₹900',
    priceValue: 900,
    peopleNeeded: 4,
    image: 'https://picsum.photos/seed/breakfast/800/600',
    date: '2026-04-11',
    shift: 'Morning',
    description:
        'Tech conference breakfast setup and service. Requires early arrival.',
    address: 'NESCO Center, Goregaon East, Mumbai',
    lat: 19.1528,
    lng: 72.8559,
  ),
];
