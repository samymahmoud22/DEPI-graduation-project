import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../controller/navigation_controller.dart';
import '../widgets/navigation_steps_sheet.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription? _accelerometerSubscription;
  static const double shakeThreshold = 15.0;
  DateTime? _lastShakeTime;


  @override
  void initState() {
    super.initState();



   
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationControllerProvider).fetchCurrentLocation();
    });
  }

  @override
  void dispose() {

    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }



  LatLng get _cameraTarget {
    final ctrl = ref.read(navigationControllerProvider);
    if (ctrl.destination != null) {
      return LatLng(ctrl.destination!.latitude, ctrl.destination!.longitude);
    }
    if (ctrl.currentPosition != null) {
      return LatLng(
        ctrl.currentPosition!.latitude,
        ctrl.currentPosition!.longitude,
      );
    }

  }

  Set<Marker> get _markers {
    final ctrl = ref.read(navigationControllerProvider);
    final t = ref.read(translationsProvider);
    final markers = <Marker>{};

    if (ctrl.currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('current'),
        position: LatLng(
          ctrl.currentPosition!.latitude,
          ctrl.currentPosition!.longitude,
        ),
        infoWindow: InfoWindow(title: t.get('you_are_here')),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    if (ctrl.destination != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          ctrl.destination!.latitude,
          ctrl.destination!.longitude,
        ),
        infoWindow: InfoWindow(title: ctrl.destination!.name),
      ));
    }

    return markers;
  }



  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(navigationControllerProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: ctrl.isNavigating
            ? _buildNavigatingState(ctrl, t)
            : ctrl.hasRoute
                ? _buildRouteFoundState(ctrl, t)
                : _buildWaitingState(ctrl, t),
      ),
    );
  }


  Widget _buildWaitingState(NavigationController ctrl, AppTranslations t) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ctrl.startVoiceInput(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          children: [

            if (ctrl.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(
                  color: AppColors.primaryButton,
                ),
              )
            else if (ctrl.currentAddress.isNotEmpty)
              _buildAddressRow(ctrl.currentAddress),

            const Spacer(),


            ScaleTransition(
              scale: ctrl.isListeningForDestination
                  ? const AlwaysStoppedAnimation(1.0)
                  : _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ctrl.isListeningForDestination
                      ? AppColors.green
                      : const Color(0xFF214D80),
                  boxShadow: [
                    BoxShadow(
                      color: (ctrl.isListeningForDestination
                              ? AppColors.green
                              : AppColors.primaryButton)
                          .withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  ctrl.isListeningForDestination
                      ? Icons.hearing_rounded
                      : Icons.mic_none_rounded,
                  color: AppColors.white,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              ctrl.isListeningForDestination
                  ? t.get('listening_dest')
                  : t.get('tap_anywhere_dest'),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (ctrl.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                ctrl.errorMessage!,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: AppColors.red, fontSize: 14),
              ),
            ],

            const Spacer(),

            
            Text(
              t.get('tap_say_name'),
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildRouteFoundState(NavigationController ctrl, AppTranslations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(t),
          const SizedBox(height: 16),


          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.location_on, color: AppColors.green, size: 28),
                const SizedBox(height: 8),
                Text(
                  ctrl.session!.destinationName,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoBadge(Icons.straighten, ctrl.session!.totalDistance),
                    const SizedBox(width: 16),
                    _infoBadge(Icons.timer, ctrl.session!.totalDuration),
                    const SizedBox(width: 16),
                    _infoBadge(Icons.directions_walk,
                        t.get('steps_count', [ctrl.session!.steps.length.toString()])),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _cameraTarget,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                markers: _markers,
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
          ),

          const SizedBox(height: 14),


          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => ctrl.startNavigation(),
              icon: const Icon(Icons.navigation_rounded, size: 24),
              label: Text(
                t.get('active_nav'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => ctrl.resetNavigation(),
              child: Text(
                t.get('choose_another_destination'),
                style: const TextStyle(color: AppColors.white70, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNavigatingState(NavigationController ctrl, AppTranslations t) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: () => ctrl.announceCurrentStep(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          children: [

            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await ctrl.stopNavigation();
                    ctrl.resetNavigation();
                  },
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
                Expanded(
                  child: Text(
                    t.get('navigating'),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.screenTitle,
                  ),
                ),
                
                IconButton(
                  onPressed: () => ctrl.toggleSafeWalk(),
                  icon: Icon(
                    ctrl.isSafeWalkEnabled
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: ctrl.isSafeWalkEnabled
                        ? AppColors.green
                        : AppColors.white70,
                  ),
                  tooltip: ctrl.isSafeWalkEnabled
                      ? t.get('disable_safe_walk')
                      : t.get('enable_safe_walk'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Destination label
                    Text(
                      t.get('to', [ctrl.session!.destinationName]),
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ctrl.isSafeWalkEnabled
                            ? AppColors.green
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ctrl.isSafeWalkEnabled
                              ? AppColors.green
                              : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ctrl.isSafeWalkEnabled ? AppColors.green : AppColors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ctrl.isSafeWalkEnabled
                                ? t.get('obstacle_active')
                                : t.get('obstacle_inactive'),
                            style: TextStyle(
                              color: ctrl.isSafeWalkEnabled ? AppColors.green : AppColors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),


                    SizedBox(
                      height: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _cameraTarget,
                            zoom: 16,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          markers: _markers,
                          onMapCreated: (controller) => _mapController = controller,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    
                    if (ctrl.currentStep != null)
                      NavigationStepCard(
                        step: ctrl.currentStep!,
                        stepIndex: ctrl.currentStepIndex,
                        totalSteps: ctrl.session!.steps.length,
                      ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),


            Text(
              t.get('tap_reannounce'),
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.white70, fontSize: 13),
            ),

            const SizedBox(height: 12),


            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ctrl.stopNavigation();
                  ctrl.resetNavigation();
                },
                icon: const Icon(Icons.stop_rounded),
                label: Text(
                  t.get('stop_nav'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(AppTranslations t) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        Expanded(
          child: Text(
            t.get('navigation'),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.screenTitle,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildAddressRow(String address) {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          color: AppColors.primaryButton,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryButton, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: AppColors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
