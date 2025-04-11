package com.example.ruta_app

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class NativeAdFactory(private val layoutInflater: LayoutInflater) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

        // Set the headline.
        adView.findViewById<TextView>(R.id.ad_headline)?.let {
            it.text = nativeAd.headline
            adView.headlineView = it
        }

        // Set the body.
        adView.findViewById<TextView>(R.id.ad_body)?.let {
            it.text = nativeAd.body
            adView.bodyView = it
        }

        // Set the app icon.
        adView.findViewById<ImageView>(R.id.ad_app_icon)?.let {
            nativeAd.icon?.drawable?.let { drawable ->
                it.setImageDrawable(drawable)
            }
            adView.iconView = it
        }

        // Set the star rating.
        adView.findViewById<RatingBar>(R.id.ad_stars)?.let {
            nativeAd.starRating?.let { rating ->
                it.rating = rating.toFloat()
                it.visibility = View.VISIBLE
            } ?: run {
                it.visibility = View.GONE
            }
            adView.starRatingView = it
        }

        // Set the advertiser name.
        adView.findViewById<TextView>(R.id.ad_advertiser)?.let {
            nativeAd.advertiser?.let { advertiser ->
                it.text = advertiser
                it.visibility = View.VISIBLE
            } ?: run {
                it.visibility = View.GONE
            }
            adView.advertiserView = it
        }

        // Set the call to action button.
        adView.findViewById<Button>(R.id.ad_call_to_action)?.let {
            it.text = nativeAd.callToAction
            adView.callToActionView = it
        }

        // Associate the native ad with the native ad view.
        adView.setNativeAd(nativeAd)

        return adView
    }
}
