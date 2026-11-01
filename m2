

## Итоговая структура проекта

```
ContactApp/
├── build.gradle.kts                      (Project)
├── settings.gradle.kts                   (Project)
├── gradle.properties                     (Project)
└── app/
    ├── build.gradle.kts                  (Module: app)
    └── src/main/
        ├── AndroidManifest.xml
        ├── java/com/example/contacts/
        │   ├── ContactViewModel.kt
        │   ├── MainActivity.kt
        │   └── EditActivity.kt
        └── res/
            ├── layout/
            │   ├── activity_main.xml
            │   └── activity_edit.xml
            └── values/
                └── strings.xml
```

Всего 9 файлов, которые мы реально пишем/меняем. Остальное Android Studio создаёт сама.

---

## Шаг 2. Настроить `app/build.gradle.kts`

Открыть файл `app/build.gradle.kts`. В блок `dependencies { ... }` добавить две строки (остальное не трогаем):

```kotlin
dependencies {
    // ... то, что уже есть (core-ktx, appcompat, material, ...)

    implementation("androidx.activity:activity-ktx:1.8.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
}
```

Зачем: `activity-ktx` даёт `by viewModels()`, а `lifecycle-viewmodel-ktx` — сам класс `ViewModel`.

Проверить, что `minSdk = 26` (обычно уже так после шага 1):

```kotlin
defaultConfig {
    applicationId = "com.example.contacts"
    minSdk = 26
    targetSdk = 34
    versionCode = 1
    versionName = "1.0"
}
```

Нажать **Sync Now** (появится плашка сверху).

---

## Шаг 3. Создать `ContactViewModel.kt`

1. В дереве проекта: `app → java → com.example.contacts`.
2. Правой кнопкой → **New → Kotlin Class/File** → **Class** → имя `ContactViewModel`.
3. Заменить содержимое на:

```kotlin
package com.example.contacts

import androidx.lifecycle.ViewModel

class ContactViewModel : ViewModel() {
    // каждый контакт = [фамилия, имя, отчество, телефон]
    val contacts = mutableListOf(
        mutableListOf("Иванов", "Иван", "Иванович", "8 (999) 999-99-99")
    )
    var index = 0        // какой контакт сейчас показываем
    var editIndex = -1   // -1 = добавляем новый, >=0 = редактируем существующий
}
```

**Почему ViewModel**: по заданию данные должны переживать переход между активностями. `ViewModel` живёт дольше Activity, поэтому `contacts`, `index`, `editIndex` не теряются, когда мы открываем `EditActivity` и возвращаемся.

---

## Шаг 4. Создать `EditActivity.kt`

1. Правой кнопкой по пакету `com.example.contacts` → **New → Activity → Empty Views Activity**.
2. **Activity Name**: `EditActivity`.
3. **Layout Name**: `activity_edit` (Studio сама подставит).
4. **Source Language**: Kotlin.
5. **Finish**.

Studio создаст `EditActivity.kt` и `activity_edit.xml`. Заменить содержимое `EditActivity.kt` на:

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

        val etLast   = findViewById<EditText>(R.id.etLastName)
        val etFirst  = findViewById<EditText>(R.id.etFirstName)
        val etMiddle = findViewById<EditText>(R.id.etMiddleName)
        val etPhone  = findViewById<EditText>(R.id.etPhone)

        // Если редактируем существующий контакт — заполняем поля
        if (vm.editIndex >= 0) {
            val c = vm.contacts[vm.editIndex]
            etLast.setText(c[0])
            etFirst.setText(c[1])
            etMiddle.setText(c[2])
            etPhone.setText(c[3])
        }

        findViewById<Button>(R.id.btnSave).setOnClickListener {
            val c = mutableListOf(
                etLast.text.toString().trim(),
                etFirst.text.toString().trim(),
                etMiddle.text.toString().trim(),
                etPhone.text.toString().trim()
            )
            if (vm.editIndex >= 0) {
                vm.contacts[vm.editIndex] = c           // изменение
                vm.index = vm.editIndex
            } else {
                vm.contacts.add(c)                       // добавление
                vm.index = vm.contacts.lastIndex
            }
            finish()   // возвращаемся на MainActivity
        }
    }
}
```

---

## Шаг 5. Разметка `activity_edit.xml`

Открыть `app/src/main/res/layout/activity_edit.xml`. Заменить полностью:

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

    <EditText
        android:id="@+id/etLastName"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Фамилия"/>

    <EditText
        android:id="@+id/etFirstName"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Имя"/>

    <EditText
        android:id="@+id/etMiddleName"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Отчество"/>

    <EditText
        android:id="@+id/etPhone"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Телефон"
        android:inputType="phone"
        android:layout_marginBottom="32dp"/>

    <Button
        android:id="@+id/btnSave"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:text="Сохранить"
        android:textColor="#FFFFFF"
        android:backgroundTint="#4CAF50"/>
</LinearLayout>
```

Ключевые `id` (`etLastName`, `etFirstName`, `etMiddleName`, `etPhone`, `btnSave`) должны совпадать с тем, что ищем в `findViewById` в шаге 4.

---

## Шаг 6. Переписать `MainActivity.kt`

Открыть `app/src/main/java/com/example/contacts/MainActivity.kt` (созданный на шаге 1) и заменить полностью:

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
        showContact(tv)

        findViewById<ImageView>(R.id.btnPrev).setOnClickListener {
            vm.index = (vm.index - 1 + vm.contacts.size) % vm.contacts.size
            showContact(tv)
        }

        findViewById<ImageView>(R.id.btnNext).setOnClickListener {
            vm.index = (vm.index + 1) % vm.contacts.size
            showContact(tv)
        }

        findViewById<Button>(R.id.btnAdd).setOnClickListener {
            vm.editIndex = -1                             // режим "добавить"
            startActivity(Intent(this, EditActivity::class.java))
        }

        findViewById<Button>(R.id.btnEdit).setOnClickListener {
            vm.editIndex = vm.index                       // режим "изменить"
            startActivity(Intent(this, EditActivity::class.java))
        }
    }

    // При возврате с EditActivity обновляем TextView
    override fun onResume() {
        super.onResume()
        showContact(findViewById(R.id.tvContact))
    }

    private fun showContact(tv: TextView) {
        val c = vm.contacts[vm.index]
        val initial1 = c[1].firstOrNull()?.let { "$it." } ?: ""
        val initial2 = c[2].firstOrNull()?.let { "$it." } ?: ""
        tv.text = "${c[0]} $initial1 $initial2".trim()
    }
}
```

Обратите внимание на `% vm.contacts.size` — это круговое переключение: с последнего «→» переходит на первый и наоборот.

---

## Шаг 7. Разметка `activity_main.xml`

Открыть `app/src/main/res/layout/activity_main.xml` и заменить полностью:

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

---

## Шаг 8. Проверить `AndroidManifest.xml`

Открыть `app/src/main/AndroidManifest.xml`. Убедиться, что там две активности — `MainActivity` (с `LAUNCHER`-фильтром) и `EditActivity`. Studio обычно добавляет `EditActivity` автоматически на шаге 4. Должно быть примерно так:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:allowBackup="true"
        android:label="Контактные данные"
        android:supportsRtl="true"
        android:theme="@style/Theme.ContactApp">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".EditActivity"
            android:exported="false" />
    </application>
</manifest>
```



## Шаг 9. Запуск и проверка

1. **Build → Make Project** (или `Ctrl+F9`). Должно собраться без ошибок.
2. Запустить на эмуляторе/устройстве (зелёный треугольник ▶).
3. Что должно работать:
   - Стартовый экран: `Иванов И. И.` в белом поле, серые стрелки «←»/«→», зелёная «Добавить», оранжевая «Изменить», всё на нежно-розовом фоне.
   - Нажать «→» или «←» — переключение по списку (при одном контакте визуально ничего не меняется).
   - Нажать «Добавить» → открывается второй экран с пустыми полями → ввести данные → «Сохранить» → вернуться назад, в TextView новый контакт.
   - Нажать «Изменить» → второй экран с заполненными полями текущего контакта → поменять → «Сохранить» → в TextView обновлённые данные.
   - Кнопка «Назад» из `EditActivity` без сохранения — данные не меняются.

---


Если на каком-то шаге Studio ругается на `R.id.xxx` — значит, в XML опечатка в `android:id`, либо не сделан **Sync/Build**. После каждого изменения XML полезно нажимать **Build → Make Project**.
