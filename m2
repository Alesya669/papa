

## Минимальная версия

### `build.gradle` (модуль) — только нужное

```groovy
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.example.contacts'
    compileSdk 34
    defaultConfig {
        applicationId "com.example.contacts"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions { jvmTarget = '1.8' }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.activity:activity-ktx:1.8.2'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0'
}
```

### `ContactViewModel.kt`

```kotlin
package com.example.contacts

import androidx.lifecycle.ViewModel

class ContactViewModel : ViewModel() {
    // [фамилия, имя, отчество, телефон]
    val contacts = mutableListOf(
        mutableListOf("Иванов", "Иван", "Иванович", "8 (999) 999-99-99")
    )
    var index = 0
    var editIndex = -1  // -1 = добавляем новый
}
```

### `MainActivity.kt`

```kotlin
package com.example.contacts

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private val vm: ContactViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tv = findViewById<TextView>(R.id.tvContact)

        fun show() {
            val c = vm.contacts[vm.index]
            val initials = "${c[1].firstOrNull() ?: ""}. ${c[2].firstOrNull() ?: ""}."
            tv.text = "${c[0]} $initials"
        }
        show()

        findViewById<ImageView>(R.id.btnPrev).setOnClickListener {
            vm.index = (vm.index - 1 + vm.contacts.size) % vm.contacts.size
            show()
        }
        findViewById<ImageView>(R.id.btnNext).setOnClickListener {
            vm.index = (vm.index + 1) % vm.contacts.size
            show()
        }
        findViewById<Button>(R.id.btnAdd).setOnClickListener {
            vm.editIndex = -1
            startActivity(Intent(this, EditActivity::class.java))
        }
        findViewById<Button>(R.id.btnEdit).setOnClickListener {
            vm.editIndex = vm.index
            startActivity(Intent(this, EditActivity::class.java))
        }
    }

    override fun onResume() {
        super.onResume()
        val c = vm.contacts[vm.index]
        val initials = "${c[1].firstOrNull() ?: ""}. ${c[2].firstOrNull() ?: ""}."
        findViewById<TextView>(R.id.tvContact).text = "${c[0]} $initials"
    }
}
```

### `EditActivity.kt`

```kotlin
package com.example.contacts

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity

class EditActivity : AppCompatActivity() {

    private val vm: ContactViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_edit)

        val etLast = findViewById<EditText>(R.id.etLastName)
        val etFirst = findViewById<EditText>(R.id.etFirstName)
        val etMiddle = findViewById<EditText>(R.id.etMiddleName)
        val etPhone = findViewById<EditText>(R.id.etPhone)

        if (vm.editIndex >= 0) {
            val c = vm.contacts[vm.editIndex]
            etLast.setText(c[0]); etFirst.setText(c[1])
            etMiddle.setText(c[2]); etPhone.setText(c[3])
        }

        findViewById<Button>(R.id.btnSave).setOnClickListener {
            val c = mutableListOf(
                etLast.text.toString().trim(),
                etFirst.text.toString().trim(),
                etMiddle.text.toString().trim(),
                etPhone.text.toString().trim()
            )
            if (vm.editIndex >= 0) vm.contacts[vm.editIndex] = c
            else vm.contacts.add(c)
            vm.index = if (vm.editIndex >= 0) vm.editIndex else vm.contacts.lastIndex
            finish()
        }
    }
}
```

### `activity_main.xml` (без drawable, только `backgroundTint`)

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center"
    android:background="#FCE4EC"
    android:padding="24dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center">

        <ImageView
            android:id="@+id/btnPrev"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:background="#6D6D6D"
            android:padding="8dp"
            android:src="@android:drawable/ic_media_previous"/>

        <TextView
            android:id="@+id/tvContact"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:gravity="center"
            android:background="#FFFFFF"
            android:padding="12dp"
            android:textSize="18sp"/>

        <ImageView
            android:id="@+id/btnNext"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:background="#6D6D6D"
            android:padding="8dp"
            android:src="@android:drawable/ic_media_next"/>
    </LinearLayout>

    <Button
        android:id="@+id/btnAdd"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginTop="120dp"
        android:text="Добавить"
        android:textColor="#FFFFFF"
        android:backgroundTint="#4CAF50"/>

    <Button
        android:id="@+id/btnEdit"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:layout_marginTop="16dp"
        android:text="Изменить"
        android:textColor="#FFFFFF"
        android:backgroundTint="#FFA726"/>
</LinearLayout>
```

### `activity_edit.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#FCE4EC"
    android:padding="24dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="добавление/изменение значений"
        android:textSize="18sp"
        android:textStyle="bold"
        android:layout_marginBottom="24dp"/>

    <EditText android:id="@+id/etLastName" android:layout_width="match_parent"
        android:layout_height="wrap_content" android:hint="Фамилия"/>
    <EditText android:id="@+id/etFirstName" android:layout_width="match_parent"
        android:layout_height="wrap_content" android:hint="Имя"/>
    <EditText android:id="@+id/etMiddleName" android:layout_width="match_parent"
        android:layout_height="wrap_content" android:hint="Отчество"/>
    <EditText android:id="@+id/etPhone" android:layout_width="match_parent"
        android:layout_height="wrap_content" android:hint="Телефон"
        android:inputType="phone" android:layout_marginBottom="32dp"/>

    <Button
        android:id="@+id/btnSave"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:text="Сохранить"
        android:textColor="#FFFFFF"
        android:backgroundTint="#4CAF50"/>
</LinearLayout>
```

### `AndroidManifest.xml` — без изменений по сути

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:label="Контактные данные" android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <activity android:name=".EditActivity" android:exported="false"/>
    </application>
</manifest>
```

