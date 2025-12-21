// android/build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// --- PERBAIKAN START: Script Penambal Namespace (Versi Safe) ---
subprojects {
    // Kita bungkus logikanya dalam fungsi lokal biar rapi
    fun fixNamespace() {
        if (project.hasProperty("android")) {
            try {
                val android = project.extensions.findByName("android")
                if (android != null) {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android)
                    
                    if (currentNamespace == null) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        
                        var newNamespace = project.group.toString()
                        if (newNamespace.isEmpty() || newNamespace == "null" || newNamespace == "android") {
                            // Ganti karakter aneh dengan underscore
                            val sanitizedName = project.name.replace(Regex("[^a-zA-Z0-9_]"), "_")
                            newNamespace = "com.example.$sanitizedName"
                        }
                        
                        setNamespace.invoke(android, newNamespace)
                        println("AUTO-FIX: Namespace '$newNamespace' ditambahkan ke project '${project.name}'")
                    }
                }
            } catch (e: Exception) {
                println("AUTO-FIX NOTE: Skip ${project.name} karena: $e")
            }
        }
    }

    // CEK STATUS DULU: Jika project sudah selesai loading, eksekusi langsung.
    // Jika belum, baru kita jadwalkan di afterEvaluate.
    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate {
            fixNamespace()
        }
    }
}
// --- PERBAIKAN END ---

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}