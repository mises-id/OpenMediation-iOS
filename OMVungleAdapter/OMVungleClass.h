#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.5 (swiftlang-1300.0.31.1 clang-1300.0.29.1)
#ifndef VUNGLEADSSDK_SWIFT_H
#define VUNGLEADSSDK_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(ns_consumed)
# define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
# define SWIFT_RELEASES_ARGUMENT
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreGraphics;
@import Foundation;
@import ObjectiveC;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="VungleAdsSDK",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

typedef SWIFT_ENUM(NSInteger, BannerSize, open) {
/// 320x50
  BannerSizeRegular = 0,
/// 300x50
  BannerSizeShort = 1,
/// 728x90
  BannerSizeLeaderboard = 2,
/// 300x250
  BannerSizeMrec = 3,
};

@class NSString;
@class NSNumber;

SWIFT_CLASS("_TtC12VungleAdsSDK12BasePublicAd")
@interface BasePublicAd : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull appId;
@property (nonatomic, readonly, copy) NSString * _Nonnull placementId;
@property (nonatomic, readonly, copy) NSString * _Nonnull eventId;
@property (nonatomic, readonly, copy) NSString * _Nonnull creativeId;
/// This method returns the playability status of the ad for the specified placement.
///
/// returns:
/// Bool value to determine if this ad can be played at this time.
- (BOOL)canPlayAd SWIFT_WARN_UNUSED_RESULT;
/// This method prepares an ad with the provided bid payload, if provided.
/// If the bid payload is nil, the waterfall flow will be executed.
/// This method will always invoke a <code>DidLoad</code> or a <code>DidFailToLoad</code> callback
/// \param bidPayload The bid payload for bidding feature.
///
- (void)load:(NSString * _Nullable)bidPayload;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM(NSInteger, ConsentStatus, open) {
  ConsentStatusAccepted = 0,
  ConsentStatusDenied = 1,
};

@class NSCoder;

/// A MediaView to display the ad’s image or video
SWIFT_CLASS("_TtC12VungleAdsSDK9MediaView")
@interface MediaView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM(NSInteger, NativeAdOptionsPosition, open) {
  NativeAdOptionsPositionTopLeft = 1,
  NativeAdOptionsPositionTopRight = 2,
  NativeAdOptionsPositionBottomLeft = 3,
  NativeAdOptionsPositionBottomRight = 4,
};




@class NSError;

SWIFT_CLASS("_TtC12VungleAdsSDK9VungleAds")
@interface VungleAds : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull sdkVersion;)
+ (NSString * _Nonnull)sdkVersion SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
/// This method initializes the Vungle SDK with the provided app id and calls the completion block
/// when finished.
/// \param appId The Vungle App ID.
///
/// \param completion The completion block that will be called when initialization finishes.
/// If there are no errors during initialization, the returned value will be nil. And vice versa.
///
+ (void)initWithAppId:(NSString * _Nonnull)appId completion:(void (^ _Nonnull)(NSError * _Nullable))completion SWIFT_METHOD_FAMILY(none);
/// This method returns the bool to check if the SDK has already been initialized successfully or not.
///
/// returns:
/// Bool to check if the SDK has already been initialized successfully or not.
+ (BOOL)isInitialized SWIFT_WARN_UNUSED_RESULT;
/// This method returns the encoded token to be used for the bidding feature.
///
/// returns:
/// The encoded string token
/// Note: The current bidding token version is 3. And, the format is:
/// “<biddingTokenVersionPrefix> + “:” <compressed/encoded token data>”
+ (NSString * _Nonnull)getBiddingToken SWIFT_WARN_UNUSED_RESULT;
/// This method sets the plugin name and version for internal identification purposes.
/// \param integrationName The plugin or adapter name.
///
/// \param version The version of the plugin or adapter.
///
+ (void)setIntegrationName:(NSString * _Nonnull)integrationName version:(NSString * _Nonnull)version;
@end

@protocol VungleBannerDelegate;

SWIFT_CLASS("_TtC12VungleAdsSDK12VungleBanner")
@interface VungleBanner : BasePublicAd
/// The delegate to receive banner ad lifecycle callbacks
@property (nonatomic, weak) id <VungleBannerDelegate> _Nullable delegate;
/// The bool value to determine whether the ad should auto-refresh.
@property (nonatomic) BOOL enableRefresh;
/// This method initializes the Vungle banner ad object.
/// \param placementId The placement id of the banner ad.
///
/// \param size The desired banner size for the banner ad.
///
- (nonnull instancetype)initWithPlacementId:(NSString * _Nonnull)placementId size:(enum BannerSize)size OBJC_DESIGNATED_INITIALIZER;
/// This method will present the banner ad in the provided UIView.
/// This view container may be placed in random positions.
/// If presentation fails, the <code>DidFailToPresent</code> callback will be invoked.
/// \param publisherView The UIView container for the banner ad.
/// The size of this container should match the specified size when this object is created.
///
- (void)presentOn:(UIView * _Nonnull)publisherView;
@end



SWIFT_PROTOCOL("_TtP12VungleAdsSDK20VungleBannerDelegate_")
@protocol VungleBannerDelegate <NSObject>
@optional
- (void)bannerAdDidLoad:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidFailToLoad:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)withError;
- (void)bannerAdWillPresent:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidPresent:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidFailToPresent:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)withError;
- (void)bannerAdWillClose:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidClose:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidTrackImpression:(VungleBanner * _Nonnull)banner;
- (void)bannerAdDidClick:(VungleBanner * _Nonnull)banner;
- (void)bannerAdWillLeaveApplication:(VungleBanner * _Nonnull)banner;
@end

@protocol VungleInterstitialDelegate;
@class UIViewController;

SWIFT_CLASS("_TtC12VungleAdsSDK18VungleInterstitial")
@interface VungleInterstitial : BasePublicAd
/// The delegate to receive interstitial ad lifecycle callbacks
@property (nonatomic, weak) id <VungleInterstitialDelegate> _Nullable delegate;
- (nonnull instancetype)initWithPlacementId:(NSString * _Nonnull)placementId OBJC_DESIGNATED_INITIALIZER;
/// This method will play the ad unit, presenting it over the <code>viewController</code> parameter
/// If presentation fails, the <code>DidFailToPresent</code> callback will be invoked.
/// \param viewController The UIViewController for presenting the interstitial ad.
/// This viewController should correspond to the ViewController at the top of the ViewController hierarchy.
///
- (void)presentWith:(UIViewController * _Nonnull)viewController;
@end



SWIFT_PROTOCOL("_TtP12VungleAdsSDK26VungleInterstitialDelegate_")
@protocol VungleInterstitialDelegate <NSObject>
@optional
- (void)interstitialAdDidLoad:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidFailToLoad:(VungleInterstitial * _Nonnull)interstitial withError:(NSError * _Nonnull)withError;
- (void)interstitialAdWillPresent:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidPresent:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidFailToPresent:(VungleInterstitial * _Nonnull)interstitial withError:(NSError * _Nonnull)withError;
- (void)interstitialAdWillClose:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidClose:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidTrackImpression:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdDidClick:(VungleInterstitial * _Nonnull)interstitial;
- (void)interstitialAdWillLeaveApplication:(VungleInterstitial * _Nonnull)interstitial;
@end

@protocol VungleNativeDelegate;
@class UIImage;
@class UIImageView;

SWIFT_CLASS("_TtC12VungleAdsSDK12VungleNative")
@interface VungleNative : BasePublicAd
/// The delegate to receive native ad lifecycle callbacks
@property (nonatomic, weak) id <VungleNativeDelegate> _Nullable delegate;
/// The application name that the ad advertises.
@property (nonatomic, readonly, copy) NSString * _Nonnull title;
/// The description of the application that the ad advertises.
@property (nonatomic, readonly, copy) NSString * _Nonnull bodyText;
/// The call to action phrase of the ad.
@property (nonatomic, readonly, copy) NSString * _Nonnull callToAction;
/// The rating for the application that the ad advertises.
@property (nonatomic, readonly) double adStarRating;
/// The sponsored text, normally “sponsored by”.
@property (nonatomic, readonly, copy) NSString * _Nonnull sponsoredText;
/// The app icon image of the ad.
@property (nonatomic, readonly, strong) UIImage * _Nullable iconImage;
/// The position for the ad choices icon. Default is TOP_RIGHT.
@property (nonatomic) enum NativeAdOptionsPosition adOptionsPosition;
- (nonnull instancetype)initWithPlacementId:(NSString * _Nonnull)placementId OBJC_DESIGNATED_INITIALIZER;
/// Pass UIViews and UIViewController to prepare and display a Native ad.
/// \param view a container view in which a native ad will be displayed. This view will be clickable.
///
/// \param mediaView a MediaView to display the ad’s image or video
///
/// \param iconImageView a UIImageView to display the app icon
///
/// \param viewController a UIViewController to present SKStoreProductViewController
///
- (void)registerViewForInteractionWithView:(UIView * _Nonnull)view mediaView:(MediaView * _Nonnull)mediaView iconImageView:(UIImageView * _Nullable)iconImageView viewController:(UIViewController * _Nullable)viewController;
/// Pass UIViews and UIViewController to prepare and display a Native ad.
/// \param view a container view in which a native ad will be displayed.
///
/// \param mediaView a MediaView to display the ad’s image or video.
///
/// \param iconImageView a UIImageView to display the app icon.
///
/// \param viewController a UIViewController to present SKStoreProductViewController.
///
/// \param clickableViews an array of UIViews that you would like to set clickable.
/// If nil or empty, the mediaView will be clickable.
///
- (void)registerViewForInteractionWithView:(UIView * _Nonnull)view mediaView:(MediaView * _Nonnull)mediaView iconImageView:(UIImageView * _Nullable)iconImageView viewController:(UIViewController * _Nullable)viewController clickableViews:(NSArray<UIView *> * _Nullable)clickableViews;
/// Dismiss the currently displaying Native ad.
- (void)unregisterView;
@end

@protocol VungleRewardedDelegate;

SWIFT_CLASS("_TtC12VungleAdsSDK14VungleRewarded")
@interface VungleRewarded : BasePublicAd
/// The delegate to receive rewarded ad lifecycle callbacks
@property (nonatomic, weak) id <VungleRewardedDelegate> _Nullable delegate;
- (nonnull instancetype)initWithPlacementId:(NSString * _Nonnull)placementId OBJC_DESIGNATED_INITIALIZER;
/// This method will play the ad unit, presenting it over the <code>viewController</code> parameter
/// If presentation fails, the <code>DidFailToPresent</code> callback will be invoked.
/// \param viewController The UIViewController for presenting the interstitial ad.
/// This viewController should correspond to the ViewController at the top of the ViewController hierarchy.
///
- (void)presentWith:(UIViewController * _Nonnull)viewController;
- (void)setUserIdWithUserId:(NSString * _Nonnull)userId;
- (void)setAlertTitleText:(NSString * _Nonnull)text;
- (void)setAlertBodyText:(NSString * _Nonnull)text;
- (void)setAlertCloseButtonText:(NSString * _Nonnull)text;
- (void)setAlertContinueButtonText:(NSString * _Nonnull)text;
@end



SWIFT_PROTOCOL("_TtP12VungleAdsSDK22VungleRewardedDelegate_")
@protocol VungleRewardedDelegate <NSObject>
@optional
- (void)rewardedAdDidLoad:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidFailToLoad:(VungleRewarded * _Nonnull)rewarded withError:(NSError * _Nonnull)withError;
- (void)rewardedAdWillPresent:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidPresent:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidFailToPresent:(VungleRewarded * _Nonnull)rewarded withError:(NSError * _Nonnull)withError;
- (void)rewardedAdWillClose:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidClose:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidTrackImpression:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidClick:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdWillLeaveApplication:(VungleRewarded * _Nonnull)rewarded;
- (void)rewardedAdDidRewardUser:(VungleRewarded * _Nonnull)rewarded;
@end

SWIFT_CLASS("_TtC12VungleAdsSDK21VunglePrivacySettings")
@interface VunglePrivacySettings : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
+ (void)setGDPRStatus:(BOOL)optIn;
+ (void)setGDPRMessageVersion:(NSString * _Nonnull)version;
+ (void)setCCPAStatus:(BOOL)optIn;
+ (void)setCOPPAStatus:(BOOL)isUserCoppa;
+ (void)setPublishIdfv:(BOOL)publish;
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
#endif

#endif
