// AI-Powered File Inspector - Advanced Brain Extension
// This demonstrates how to combine your existing inheritance patterns with AI assistance

using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class AIFileInspector : SuperBrain
{
    [SerializeField] private string watchDirectory = @"C:\";
    [SerializeField] private List<string> targetExtensions = new List<string> { ".cs", ".exe", ".dll" };
    
    private FileSystemWatcher watcher;
    private Dictionary<string, DateTime> fileChangeLog = new Dictionary<string, DateTime>();
    
    // Override the Think method to add AI-powered file analysis
    public override void Think()
    {
        base.Think(); // Still call SuperBrain.Think()
        
        // AI-enhanced thinking: analyze file patterns
        AnalyzeFilePatterns();
        
        Debug.Log($"AI Inspector: Monitoring {watchDirectory} for {string.Join(", ", targetExtensions)}");
    }
    
    void Start()
    {
        base.Start();
        InitializeFileWatcher();
    }
    
    private void InitializeFileWatcher()
    {
        // ChatGPT: Create a robust file watcher that handles permissions gracefully
        try
        {
            watcher = new FileSystemWatcher(watchDirectory);
            watcher.Filter = "*.*";
            watcher.IncludeSubdirectories = true;
            
            // Subscribe to events
            watcher.Created += OnFileChanged;
            watcher.Changed += OnFileChanged;
            watcher.Deleted += OnFileChanged;
            
            watcher.EnableRaisingEvents = true;
            Debug.Log("AI File Inspector: Watcher initialized successfully");
        }
        catch (UnauthorizedAccessException ex)
        {
            Debug.LogWarning($"AI Inspector: Permission denied for {watchDirectory}. Error: {ex.Message}");
            // Fallback to user directory
            watchDirectory = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            InitializeFileWatcher(); // Retry with user directory
        }
        catch (Exception ex)
        {
            Debug.LogError($"AI Inspector: Failed to initialize watcher. Error: {ex.Message}");
        }
    }
    
    private void OnFileChanged(object sender, FileSystemEventArgs e)
    {
        // Only log files with target extensions
        string extension = Path.GetExtension(e.FullPath).ToLower();
        if (targetExtensions.Contains(extension))
        {
            LogFileChange(e.FullPath, e.ChangeType.ToString());
            
            // AI Enhancement: Trigger analysis for code files
            if (extension == ".cs")
            {
                AnalyzeCodeFile(e.FullPath);
            }
        }
    }
    
    private void LogFileChange(string filePath, string changeType)
    {
        DateTime now = DateTime.Now;
        fileChangeLog[filePath] = now;
        
        Debug.Log($"AI Inspector [{now:HH:mm:ss}]: {changeType} - {Path.GetFileName(filePath)}");
        
        // Keep log size manageable
        if (fileChangeLog.Count > 1000)
        {
            var oldestEntries = fileChangeLog.OrderBy(kvp => kvp.Value).Take(100);
            foreach (var entry in oldestEntries.ToList())
            {
                fileChangeLog.Remove(entry.Key);
            }
        }
    }
    
    private void AnalyzeCodeFile(string filePath)
    {
        // ChatGPT: Add basic code analysis patterns
        try
        {
            if (File.Exists(filePath))
            {
                string content = File.ReadAllText(filePath);
                
                // Simple pattern analysis
                int classCount = CountOccurrences(content, "class ");
                int methodCount = CountOccurrences(content, "public ") + CountOccurrences(content, "private ");
                int commentCount = CountOccurrences(content, "//");
                
                Debug.Log($"AI Code Analysis for {Path.GetFileName(filePath)}: " +
                         $"{classCount} classes, {methodCount} methods, {commentCount} comments");
                
                // AI Insight: Flag potential issues
                if (commentCount < methodCount * 0.5f)
                {
                    Debug.LogWarning($"AI Insight: {Path.GetFileName(filePath)} may need more documentation");
                }
            }
        }
        catch (Exception ex)
        {
            Debug.LogWarning($"AI Inspector: Could not analyze {filePath}. Error: {ex.Message}");
        }
    }
    
    private void AnalyzeFilePatterns()
    {
        // AI-powered pattern recognition on logged files
        var recentChanges = fileChangeLog.Where(kvp => 
            DateTime.Now.Subtract(kvp.Value).TotalMinutes < 5).ToList();
            
        if (recentChanges.Count > 10)
        {
            Debug.Log($"AI Pattern Alert: High file activity detected ({recentChanges.Count} changes in 5 minutes)");
        }
        
        // Group by file type
        var changesByType = recentChanges
            .GroupBy(kvp => Path.GetExtension(kvp.Key))
            .OrderByDescending(g => g.Count());
            
        foreach (var group in changesByType.Take(3))
        {
            Debug.Log($"AI Pattern: {group.Key} files - {group.Count()} recent changes");
        }
    }
    
    private int CountOccurrences(string text, string pattern)
    {
        return (text.Length - text.Replace(pattern, "").Length) / pattern.Length;
    }
    
    // Public API for external tools to query our intelligence
    public List<string> GetRecentFiles(int minutes = 10)
    {
        return fileChangeLog
            .Where(kvp => DateTime.Now.Subtract(kvp.Value).TotalMinutes < minutes)
            .Select(kvp => kvp.Key)
            .ToList();
    }
    
    public Dictionary<string, int> GetFileTypeStats()
    {
        return fileChangeLog.Keys
            .GroupBy(path => Path.GetExtension(path))
            .ToDictionary(g => g.Key, g => g.Count());
    }
    
    void OnDestroy()
    {
        // Clean up the file watcher
        if (watcher != null)
        {
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();
            Debug.Log("AI File Inspector: Watcher disposed");
        }
    }
}
