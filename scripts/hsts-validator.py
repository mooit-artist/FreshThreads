#!/usr/bin/env python3
"""
HSTS Compliance Reporter for FreshThreads LLC
Generates comprehensive HSTS implementation reports
"""

import os
import re
import glob
import json
from datetime import datetime


class HSTSReporter:
    def __init__(self):
        self.docs_dir = "docs"
        self.report_file = "security-reports/hsts-compliance-report.json"
        self.html_report_file = "security-reports/hsts-report.html"
        self.files_data = []

    def get_html_files(self):
        """Get all HTML files in the docs directory"""
        pattern = os.path.join(self.docs_dir, "*.html")
        return glob.glob(pattern)

    def analyze_hsts_implementation(self, content):
        """Analyze HSTS implementation in content"""
        # Look for HSTS meta tag
        hsts_pattern = r'<meta\s+http-equiv=["\']Strict-Transport-Security["\'][^>]*content=["\']([^"\']*)["\'][^>]*>'
        match = re.search(hsts_pattern, content, re.IGNORECASE)

        analysis = {
            "has_hsts": False,
            "policy": "",
            "max_age": None,
            "include_subdomains": False,
            "preload": False,
            "issues": [],
            "score": 0
        }

        if not match:
            analysis["issues"].append("HSTS header not found")
            return analysis

        analysis["has_hsts"] = True
        policy = match.group(1)
        analysis["policy"] = policy

        # Analyze max-age
        max_age_pattern = r'max-age=(\d+)'
        max_age_match = re.search(max_age_pattern, policy)
        if max_age_match:
            analysis["max_age"] = int(max_age_match.group(1))
            if analysis["max_age"] >= 31536000:  # 1 year
                analysis["score"] += 40
            elif analysis["max_age"] >= 15768000:  # 6 months
                analysis["score"] += 30
                analysis["issues"].append(
                    "max-age less than recommended 1 year")
            else:
                analysis["score"] += 10
                analysis["issues"].append(
                    "max-age too short (recommended: 31536000)")
        else:
            analysis["issues"].append("max-age directive missing")

        # Check includeSubDomains
        if 'includeSubDomains' in policy:
            analysis["include_subdomains"] = True
            analysis["score"] += 30
        else:
            analysis["issues"].append("includeSubDomains directive missing")

        # Check preload
        if 'preload' in policy:
            analysis["preload"] = True
            analysis["score"] += 30
        else:
            analysis["issues"].append("preload directive missing")

        return analysis

    def analyze_file(self, file_path):
        """Analyze HSTS implementation in a single file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            analysis = self.analyze_hsts_implementation(content)

            file_data = {
                "file": file_path,
                "timestamp": datetime.now().isoformat(),
                "analysis": analysis
            }

            self.files_data.append(file_data)
            return file_data

        except Exception as e:
            error_data = {
                "file": file_path,
                "timestamp": datetime.now().isoformat(),
                "error": str(e),
                "analysis": {"has_hsts": False, "score": 0, "issues": [f"Error reading file: {e}"]}
            }
            self.files_data.append(error_data)
            return error_data

    def generate_summary_stats(self):
        """Generate summary statistics"""
        total_files = len(self.files_data)
        files_with_hsts = sum(1 for f in self.files_data if f.get(
            "analysis", {}).get("has_hsts", False))

        scores = [f.get("analysis", {}).get("score", 0)
                  for f in self.files_data]
        avg_score = sum(scores) / len(scores) if scores else 0

        compliance_issues = []
        for file_data in self.files_data:
            issues = file_data.get("analysis", {}).get("issues", [])
            compliance_issues.extend(issues)

        return {
            "total_files": total_files,
            "files_with_hsts": files_with_hsts,
            "files_without_hsts": total_files - files_with_hsts,
            "compliance_rate": (files_with_hsts / total_files * 100) if total_files > 0 else 0,
            "average_score": avg_score,
            "total_issues": len(compliance_issues),
            "common_issues": self.get_common_issues()
        }

    def get_common_issues(self):
        """Get most common HSTS issues"""
        issue_counts = {}
        for file_data in self.files_data:
            issues = file_data.get("analysis", {}).get("issues", [])
            for issue in issues:
                issue_counts[issue] = issue_counts.get(issue, 0) + 1

        return sorted(issue_counts.items(), key=lambda x: x[1], reverse=True)

    def generate_json_report(self):
        """Generate JSON report"""
        report = {
            "report_type": "HSTS Compliance Report",
            "generated_at": datetime.now().isoformat(),
            "project": "FreshThreads LLC",
            "summary": self.generate_summary_stats(),
            "files": self.files_data,
            "recommendations": self.generate_recommendations()
        }

        # Ensure directory exists
        os.makedirs(os.path.dirname(self.report_file), exist_ok=True)

        with open(self.report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        return report

    def generate_html_report(self, report_data):
        """Generate HTML report"""
        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Strict-Transport-Security" content="max-age=31536000; includeSubDomains; preload">
    <title>HSTS Compliance Report - FreshThreads LLC</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 40px; line-height: 1.6; }}
        .header {{ border-bottom: 3px solid #000; padding-bottom: 20px; margin-bottom: 30px; }}
        .summary {{ background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }}
        .file-analysis {{ border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }}
        .score {{ font-weight: bold; }}
        .score.high {{ color: #28a745; }}
        .score.medium {{ color: #ffc107; }}
        .score.low {{ color: #dc3545; }}
        .issues {{ background: #fff3cd; padding: 10px; border-radius: 4px; margin: 10px 0; }}
        .recommendations {{ background: #d1ecf1; padding: 15px; border-radius: 8px; margin: 20px 0; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🔒 HSTS Compliance Report</h1>
        <p><strong>Project:</strong> FreshThreads LLC</p>
        <p><strong>Generated:</strong> {report_data['generated_at']}</p>
    </div>

    <div class="summary">
        <h2>📊 Summary Statistics</h2>
        <p><strong>Total Files:</strong> {report_data['summary']['total_files']}</p>
        <p><strong>Files with HSTS:</strong> {report_data['summary']['files_with_hsts']}</p>
        <p><strong>Compliance Rate:</strong> {report_data['summary']['compliance_rate']:.1f}%</p>
        <p><strong>Average Score:</strong> {report_data['summary']['average_score']:.1f}/100</p>
        <p><strong>Total Issues:</strong> {report_data['summary']['total_issues']}</p>
    </div>

    <h2>📁 File Analysis</h2>
"""

        for file_data in report_data['files']:
            analysis = file_data.get('analysis', {})
            score = analysis.get('score', 0)
            score_class = 'high' if score >= 80 else 'medium' if score >= 50 else 'low'

            html_content += f"""
    <div class="file-analysis">
        <h3>{file_data['file']}</h3>
        <p class="score {score_class}">Security Score: {score}/100</p>
        <p><strong>Has HSTS:</strong> {'✅ Yes' if analysis.get('has_hsts') else '❌ No'}</p>
"""

            if analysis.get('policy'):
                html_content += f"<p><strong>Policy:</strong> <code>{analysis['policy']}</code></p>"

            if analysis.get('issues'):
                html_content += '<div class="issues"><h4>Issues:</h4><ul>'
                for issue in analysis['issues']:
                    html_content += f'<li>{issue}</li>'
                html_content += '</ul></div>'

            html_content += '</div>'

        html_content += f"""
    <div class="recommendations">
        <h2>💡 Recommendations</h2>
        <ul>
"""
        for rec in report_data['recommendations']:
            html_content += f'<li>{rec}</li>'

        html_content += """
        </ul>
    </div>
</body>
</html>"""

        with open(self.html_report_file, 'w', encoding='utf-8') as f:
            f.write(html_content)

    def generate_recommendations(self):
        """Generate recommendations based on analysis"""
        recommendations = []
        summary = self.generate_summary_stats()

        if summary['files_without_hsts'] > 0:
            recommendations.append(
                f"Add HSTS headers to {summary['files_without_hsts']} files missing them")

        common_issues = summary['common_issues']
        if common_issues:
            top_issue = common_issues[0]
            recommendations.append(
                f"Address most common issue: {top_issue[0]} (affects {top_issue[1]} files)")

        if summary['average_score'] < 100:
            recommendations.append(
                "Improve HSTS policies to achieve maximum security score")

        recommendations.extend([
            "Submit domain to HSTS preload list at hstspreload.org",
            "Implement HSTS at web server level for production",
            "Test HSTS implementation with online security tools",
            "Monitor HSTS compliance regularly"
        ])

        return recommendations

    def run(self):
        """Main execution function"""
        print("🔒 FreshThreads LLC - HSTS Compliance Reporter")
        print("=" * 50)

        if not os.path.exists(self.docs_dir):
            print(f"❌ Directory '{self.docs_dir}' not found!")
            return

        html_files = self.get_html_files()
        if not html_files:
            print(f"❌ No HTML files found in '{self.docs_dir}'")
            return

        print(f"📁 Analyzing {len(html_files)} HTML files...")

        for file_path in html_files:
            file_data = self.analyze_file(file_path)
            analysis = file_data.get('analysis', {})
            score = analysis.get('score', 0)
            print(f"  📄 {file_path}: {score}/100 points")

        # Generate reports
        print("\n📊 Generating reports...")
        report_data = self.generate_json_report()
        self.generate_html_report(report_data)

        # Summary
        summary = report_data['summary']
        print(f"\n📋 HSTS Compliance Summary:")
        print(f"  📁 Total files: {summary['total_files']}")
        print(f"  ✅ Files with HSTS: {summary['files_with_hsts']}")
        print(f"  📊 Compliance rate: {summary['compliance_rate']:.1f}%")
        print(f"  ⭐ Average score: {summary['average_score']:.1f}/100")

        print(f"\n📄 Reports generated:")
        print(f"  📊 JSON Report: {self.report_file}")
        print(f"  🌐 HTML Report: {self.html_report_file}")

        print(f"\n💡 Next Steps:")
        print(f"  • Review detailed reports for specific issues")
        print(f"  • Run 'make hsts-add' to add missing HSTS headers")
        print(f"  • Test implementation with online HSTS tools")


if __name__ == "__main__":
    reporter = HSTSReporter()
    reporter.run()
